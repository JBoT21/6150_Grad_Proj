const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { OpenAI } = require('openai');

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS and JSON body parsing
app.use(cors());
app.use(express.json());

// Initialize OpenAI client
const hasApiKey = process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_api_key_here';
const openai = hasApiKey ? new OpenAI() : null;

app.post('/api/story', async (req, res) => {
  try {
const { words, prompt } = req.body;

// Either a prompt, or a list of words
if (
  (!prompt || prompt.trim() === "") &&
  (!Array.isArray(words) || words.length === 0)
) {
  return res.status(400).json({
    error: 'Provide either a "prompt" string or a "words" array.'
  });
}

    let story;

    if (!hasApiKey) {
      console.warn('OPENAI_API_KEY is not set. Running in MOCK mode.');
      // Generate a simple mock story using the words provided
     if (prompt) {
       story =
         `Once upon a time, ${prompt}. ` +
         `Everyone learned that kindness, courage, and imagination can solve almost any problem.`;
     } else {
       story =
         `A ${words.includes('little') ? 'little' : 'small'} ` +
         `${words.includes('dog') ? 'dog' : 'puppy'} named Buddy loved to ` +
         `${words.includes('run') ? 'run' : 'play'} and ` +
         `${words.includes('jump') ? 'jump' : 'hop'}. ` +
         `He felt very ${words.includes('happy') ? 'happy' : 'glad'} under the bright ` +
         `${words.includes('yellow') ? 'yellow' : 'warm'} sun.`;
     }

     console.log("Mock story generated successfully!");
    } else {
      // Build a Dolch-based prompt
      let systemPrompt;
      let userPrompt;

      if (prompt) {

        systemPrompt = `
      You are a creative children's author.

      Write an engaging children's story based on the user's idea.

      Requirements:
      - 300–500 words
      - Beginning, middle, and end
      - Friendly tone
      - Positive ending
      - Appropriate for ages 5–8
      - Return ONLY the story text.
      `;

        userPrompt = prompt;

        console.log("Generating story from prompt.");

      } else {

        systemPrompt = `
      You are a helpful reading assistant for children.
      Generate a short, engaging story (1–3 sentences) using the supplied vocabulary words.
      Return ONLY the story text.
      `;

        userPrompt = `Generate a story using these words: ${words.join(", ")}`;
        console.log(`Generating story using words: ${words.join(", ")}`);
      }

      const response = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.7,
        max_tokens: 150
      });

      story = response.choices[0].message.content.trim();
      console.log('Story generated successfully!');
    }

    return res.json({ story });
  } catch (error) {
    console.error('Error generating story:', error);
    return res.status(500).json({ error: error.message || 'Failed to generate story' });
  }
});

// Basic health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`Backend proxy server listening on port ${port}`);
});
