const testWords = ['jump', 'run', 'happy', 'little', 'dog', 'yellow'];

console.log('Starting end-to-end story generation test...');
console.log(`Sending words: ${testWords.join(', ')}`);

async function runTest() {
  try {
    const response = await fetch('http://localhost:3000/api/story', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ words: testWords }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Server returned status ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    console.log('\n--- SUCCESS! STORY RECEIVED ---');
    console.log(data.story);
    console.log('-------------------------------\n');
  } catch (error) {
    console.error('\n--- TEST FAILED ---');
    console.error(error.message);
    console.error('Please make sure the proxy server is running (node server.js) and the OPENAI_API_KEY is configured in .env.\n');
    process.exit(1);
  }
}

runTest();
