# Project Mathematics

Outline of the eventual website
-------
The idea for the website, which will eventually have sibling mobile supporting apps - is that of a maths education website that wholly encompass all aspects of a student's need delivered in a consistent way.

The MVP will contain
-------
* A course that covers all topics for 11 plus maths exams.
* High quality video tutorials on each topic.
* Unlimited supply of online questions and detailed solutions (solutions given in stages following hints).
* Track student progress through the *course track*.  Each topic has a base level of difficulty a student must achieve in order to move onto topics for which the current topic is a prerequiste.
* An achievement system - yet to be decided (points? badges? levels?)
* For each student, on a given topic, the website generates questions on the same topic of higher level of difficulty based on what the student has completed already.
* Student profile and parent dashboard.
* Unlimited supply of computer generated worksheets based on the student's current level on any topic, together with detailed solution sheet, for if the student/parent wish to do handwritten practice.
* Unlimited supply of computer generated 11 plus practice papers based on the student's current level across all 11 plus topics, together with detailed solution sheet.

Post MVP course list (*these will definetely happen*)
-------
All additional course tracks will follow the same structure of the 11 plus course - videos, online questions, offline worksheets and practice paper.
* GCSE Maths course (mostly computer generated content)
* Maths problem solving course based on GCSE level of knowledge (non-generated problems)
* A-level Maths course (mostly computer generated content)
* A-level Further Maths course (mostly computer genenated content)

Post MVP feature ideas / wish-list (*not limited to these*)
-------
- *ebook* with printable worksheets and practice papers on any topic.  This can be a seperate product line.  The idea is that the contents of the website will more than serve function of current school text books and much more.
- *teacher* portal - allow teachers to set up teaching plans, so that the website generate content based on the teacher's teaching plans.  This is also a seperate product line.  This can also be extended for school usage.
- *one-to-one sessions* have tutors/teachers on the site giving either written comments on student's practice paper or online lesson to discuss the student's work.
- *weekly fun maths-jam* lead by a teacher of the site, live-streamed session (akin to twitch), dicuss an interesting problem with students.

*Ok before we get too carried away...here and now...*


# Outline of *this* repository

This repository contains the ruby-written maths content generation engine that will eventually power the website described above for maths learning for students between ages 8 - 18.  Currently making maths 11 plus (keystage 2) topics.

Structure
--------
Each *topic is a class* which implements the following public API (public methods):
```ruby
self.generate_question(parameters)  #parameter is a hash
# return hash => {question: question,solution: solution}
```
```ruby
self.latex(question)  #the argument is the returned hash from previous method
# return hash => {question_latex:question_latex,solution_latex:solution_latex}
```
The returned hash contains the latex string for the question and the latex string for the solutions.

##### QuestionGenerator module

This module is responsible for two methods which invokes topic question generators from all the topic classes to produce arrays of questions for worksheet and practice paper.

##### LatexPrinter class

This class is responsible for rendering the generated questions array from the QuestionGenerator module together with some other information about the practice paper or worksheet (e.g. student name, paper serial) into latex string.  One for questions, one for solutions.

##### Expression and Step class

These two classes are central and especially important, as almost every topic class will utilize these two classes to do the equation solving.  
* A mathematical ```Step ``` consists of an *operation* (+,- etc), *value*, and *direction*.
* A mathematical ```Expression``` consists of an array of ```Step```s.
* For example *x + 2* is an Expression consisting of two steps:  (no-operation,'x',right) and (add,2,right).
* *x + 2* can also be expressed as these two steps:  (no-operation,2,right) and (add,'x',left).
* The *value* of a ```Step``` can also be an ```Expression```, thus *11 - (x+2)* can be expressioned as (no-operation,Expression(x+2),right) and (subtract,11,left).

This system allows most maths expressions to be expressed flexibly in many different ways depending on need of the context.

Some of the critical methods that ```Expression``` need to implement are:
* ```expand``` to expand something like *(x+2)(y-3)* into a sum *xy+2y-3x-6*, and any such expressions such as *((x+2)(y-3)+4)(a-b+5)*.
* ```latex``` return latex string representation of any expression.
* ```expand_to_rsum``` short for expand to a sum of rationals.  This is a more general way to expand, it will expand an expression involving fractions/division into a sum of fractions.  Note it will need to deal with fractions inside fraction situation.
* ```simplify``` cancelling terms, collecting like terms.

The above methods are also the most challenging to write, I have spent too long writing and rewriting them.  And an effort to refactor these methods is the main reason for all the rewrites.  In my latest attempt (5th? 6th? lost count...), I feel I may have it, but I am looking for improvements still to make it more readable and organize better if possible.

##### Equation class

This does not do too much at the present, apart from holding a left-hand-side expression and a right-hand-side expression.  It may have more responsibilities to solve certain generic equation forms later.

## Latest Progress and Ordered To Do List

Currently, ```expand,latex,expand_to_rsum``` have been rewritten.  To do:
* Rewrite ```simplify```.
* Amend ```LinearEquation```, ```Fraction``` to adopt to the new ```latex``` method of the expression class.
* Amend ```LatexPrinter``` tests.
* Complete ```AgeProblem``` topic class.
