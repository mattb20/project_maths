require './models/linear_equation'
require './models/age_problem'

module ContentGenerator

  TOPICS = {
    linear_equation:{work_sheet_title:'Linear Equation',prefix:'LEQ',
      class_name:LinearEquation},
    fraction:{work_sheet_title:'Fraction',prefix:'FRA',
      class_name:Fraction},
    age_problem:{work_sheet_title:'Age Problem',prefix:'AGP',
      class_name:AgeProblem,skip_align:true,text_start:true}
    }

  def generate_worksheet_questions(number_of_questions=10,klass=Fraction,parameters={})
    questions = []
    number_of_questions.times {questions << klass.generate_question(parameters)}
    questions
  end

  def generate_paper_questions(contents=[])
    questions = []
    contents.each do |content|
      content[:parameters] ||= {}
      content[:number_of_questions] ||= 1
      content[:work_space] ||= 200
      content[:number_of_questions].times do
        question = TOPICS[content[:topic]][:class_name].generate_question(content[:parameters])
        questions << {question:question,topic:content[:topic],work_space:content[:work_space]}
      end
    end
    questions
  end

end
