# Milestone 0

## Folder Layout
- **Screens**  
  The different types of widget trees/screens the users (teacher or student) will see.
- **Models**  
  The various classes/objects that define our app’s data.
- **Widget**  
  Reusable widget files and data structures.
- **Data**  
  The wordlist data used for students.

---

## Screens

### Login Screen
The first screen users will see.  
Users enter a username and password.  
Each user has a **role** (Student or Teacher) which determines their navigation path.

### Wordlist Selector (Student)
Students choose which word list to practice.  
**Options:** Phonic or Custom lists.

### Practice Screen (Student)
Shows **one word card at a time** with a button to record pronunciation.

### Feedback Screen (Student)
Appears after practice to show:
- Success or Needs Work indicator
- Guidance/tips
- Score of the attempt

### Progress Screen (Student)
Displays **simple progress charts** over time for each word list.

### Dashboard (Teacher)
Shows:
- Averages
- Attempts
- Struggling words
- Students list

Extra teacher features:
- Upload CSV of custom lists
- Toggle audio retention per student
- Filter by **student**, **wordlist**, and **time window**

---

## Models

### User
| Field | Type | Notes |
|-------|------|------|
| UID | int | Identifier |
| Email | String | User login / contact |
| Name | String | Full name |
| Role | String | Student or Teacher |

### Wordlist
| Field | Type | Notes |
|-------|------|------|
| ID | int | Word list identifier |
| Word | String | Practice word |
| Category | String | Phonic or Custom |
| Sentence | String | Example usage |

### Settings
| Field | Type | Notes |
|-------|------|------|
| UID | int | Links to user |
| Retain Audio | bool | Toggle for storing recording attempts |
| Retention Time | int | Duration of audio storage |

### Attempts
Tracks each pronunciation effort:

| Field | Type | Notes |
|-------|------|------|
| ID | int | ID of Attempt
| UID | int | ID of Student
| Student Name | String | Name of Student
| Wordlist ID| Int | ID of wordlist word is in
| Word | String | Word Text
| Score | int | Score of attempt
| Feedback | String | Feedback base on audio
| Audio | String | Audio Reference
| CreatedOn | Date object | Time Attempt was created

---

## Widgets
- **Word Card**: Displays a word and example sentence
- **Record Button**: Records student audio
- **Feedback Card**: Shows score and feedback message
- **Progress Chart**: Visual representation of word list progress

---

## Data
- **Seed_words.csv**: Default set of words (phonic or custom)

---

## Navigation Flow
Student:

Login -> Wordlist Selector -> Practice -> Feedback -> Progress -> Wordlist Selector or Practice

Teacher:

Login -> Dashboard
