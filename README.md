# Milestone 0

Folder Layout:
Screens - The different types of widget trees/screens the models users (teacher or student) will see
Models - The different types of classes/objects we will have for our app
Widget - Reusable widget files and data structures
Data - The wordlist data that will be used for students

Screens:
Login Screen - The first screen users will see. Users will enter in a username and password. Each user will have a category associated with them(Student or Teacher) and will navigate to specific screens depending on the user type.

Wordlist Selector(Student) - This is the screen students will see after the login page. Students will choose specific word lists (phonic or custom) on the screen to practice.

Practice Screen(Student) - The screen where students will practice pronouncing their words. Shows one word card at a time and has a button to record sounds.

Feedback Screen(Student) - Will show after practice to show a success or needs work indicator. Also shows some guidance/tips and the score of the attempt.

Progress(Student) - Will show after feedback and show students simple charts of the progress of their journey within the word list

Dashboard(Teacher) - Will show averages, attempts, struggling words, students. There will also be an upload csv button for teachers to upload custom lists. Teachers have the option to retain audio by toggling a button. Teacher can filter on students, wordlist, and time window.

Models:

User: The user of the app(Student or Teacher).
UID(int)
Email(String)
Name(String)
Role(String - Student or Teacher)

Wordlist: The list of words that a student can practice.
ID(int)
Word(String)
Category(String - Phonic or Custom)
Sentence(String)

Settings: The options for the app
UID(Int)
Retain Audio(Bool)
Retention Time (Int)

Attempts: The attempts per user for each practice on a specific word
ID(int)
UID(int)
Student Name(String)
Wordlist ID(Int)
Word(String)
Score(Int)
Feedback(String)
Audio(String)
CreateOn(Date Object)

Widgets:
Word Card - A card widget that will represent the word and example sentences
Record Button - The button to start and record sounds
Feedback Card - A card widget displaying feedback and score
Progress Chart - Chart widgets that will represent progress for each wordlist

Data:
Seed_words.csv - The list of unable words that students can see (phonic or custom)

Navigation
Student:

Login -> Wordlist Selector -> Practice -> Feedback -> Progress -> Wordlist Selector or Practice

Teacher:

Login -> Dashboard
