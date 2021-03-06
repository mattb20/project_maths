require './models/expression'


describe Expression do
  describe '#initialize/new' do
    let(:expression){described_class.new()}

    it 'has with an array of equation-steps' do
      expect(expression.steps).to eq []
    end
  end

  describe '#==' do
    it 'asserts equality when all steps are equal' do
      expression1 = Expression.new([Step.new(:add,5,:lft),Step.new(:mtp,'x')])
      expression2 = Expression.new([Step.new(:add,5,:lft),Step.new(:mtp,'x')])
      expect(expression1).to eq expression2
    end

    it 'asserts inequality when at not all steps are equal' do
      expression1 = Expression.new([Step.new(:add,5),Step.new(:mtp,'x')])
      expression2 = Expression.new([Step.new(:add,5,:lft),Step.new(:mtp,'x')])
      expect(expression1).not_to eq expression2
    end

    it 'returns false when compared expression is not an expression' do |variable|
      expression1 = Expression.new([Step.new(:add,5),Step.new(:mtp,'x')])
      expression2 = 'not an expression'
      expect(expression1).not_to eq expression2
    end
  end

  describe '#copy' do
    context 'making a copy of self with simple steps' do
      shared_context 'self copy' do
        before(:all) do
          @step_1 = Step.new(:add,5,:lft)
          @step_2 = Step.new(:sbt,7)
          @expression = Expression.new([@step_1,@step_2])
          @expression_copy = @expression.copy
        end
      end

      include_context 'self copy'

      it 'returns an instance of the class with same states' do
        expect(@expression).to eq @expression_copy
      end

      it 'returns a different instance of the class with same states' do
        expect(@expression.object_id).not_to eq @expression_copy.object_id
      end
    end

    context 'making a copy of self steps contain expression values' do
      shared_context 'self copy 2' do
        before(:all) do
          @step_1 = Step.new(:add,Expression.new([Step.new(:mtp,'x')]),:lft)
          @step_2 = Step.new(:sbt,7)
          @expression = Expression.new([@step_1,@step_2])
          @expression_copy = @expression.copy
        end
      end

      include_context 'self copy 2'

      it 'returns an instance of the class with same states' do
        expect(@expression).to eq @expression_copy
      end

      it 'returns a different instance of the class with same states' do
        expect(@expression.object_id).not_to eq @expression_copy.object_id
      end

      it 'returns a different instance of the value expressions' do
        exp_1_id = @expression.steps.first.val.object_id
        exp_1_copy_id = @expression_copy.steps.first.val.object_id
        expect(exp_1_id).not_to eq exp_1_copy_id
      end
    end
  end

  describe '#is_m_form?' do
    it 'returns false for an empty expression' do
      expression = Expression.new()
      expect(expression.is_m_form?).to be false
    end

    it 'return true for expression with only elementary m steps' do
      expression = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      expect(expression.is_m_form?).to be true
    end

    it 'returns false if a step value is an Expression' do
      expression = Expression.new([Step.new(nil,Expression.new()),Step.new(:mtp,'x')])
      expect(expression.is_m_form?).to be false
    end

    it 'returns false if a step ops is addition' do
      expression = Expression.new([Step.new(nil,5),Step.new(:add,'x')])
      expect(expression.is_m_form?).to be false
    end

    it 'returns false if a step ops is subtraction' do
      expression = Expression.new([Step.new(nil,5),Step.new(:sbt,'x')])
      expect(expression.is_m_form?).to be false
    end

    it 'returns false if a step ops is division' do
      expression = Expression.new([Step.new(nil,5),Step.new(:div,'x')])
      expect(expression.is_m_form?).to be false
    end

    it 'returns true with multiple elementary m steps' do
      expression = Expression.new([Step.new(nil,5),Step.new(:mtp,'x'),
        Step.new(:mtp,3),Step.new(:mtp,'y')])
      expect(expression.is_m_form?).to be true
    end
  end

  describe '#is_m_form_sum?' do
    it 'returns true for empty expression' do
      expression = Expression.new()
      expect(expression.is_m_form_sum?).to be true
    end

    it 'returns true for expression with only initial elementary step' do
      step1 = Step.new(nil,3)
      expression = Expression.new([step1])
      expect(expression.is_m_form_sum?).to be true
    end

    it 'returns true for expression with only initial m_form step' do
      step1 = Step.new(nil,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      expression = Expression.new([step1])
      expect(expression.is_m_form_sum?).to be true
    end

    it 'returns true for a sum of m-form or elementary steps' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be true
    end

    it 'returns false when one of the steps is multiply' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:mtp,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be false
    end

    it 'returns false when one of the steps is divide' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:div,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be false
    end

    it 'returns false when one step is left addition' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]),:lft)
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be false
    end

    it 'returns false when one step is left subtraction' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:sbt,Expression.new([Step.new(nil,'y')]),:lft)
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be false
    end

    it 'returns false when one of the steps is not elementary or m-form' do
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,Expression.new())]))
      expression = Expression.new([step1,step2,step3,step4])
      expect(expression.is_m_form_sum?).to be false
    end
  end

  describe '#is_rational?' do
    it 'is true for elementary initial step divide by elmentary step' do
      step_first = Step.new(nil,4)
      step_last = Step.new(:div,'x')
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'is true for elementary initial step divide by m-form step' do
      step_first = Step.new(nil,4)
      m_form = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_last = Step.new(:div,m_form)
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'is true for elementary initial step divide by m-form-sum step' do
      step_first = Step.new(nil,4)
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      m_form_sum = Expression.new([step1,step2,step3,step4])
      step_last = Step.new(:div,m_form_sum)
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'is true for m-form initial step divide by elementary step' do
      m_form_top = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_first = Step.new(nil,m_form_top)
      step_last = Step.new(:div,'x')
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'is true for m-form initial step divide by m-form step' do
      m_form_top = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_first = Step.new(nil,m_form_top)
      m_form_bot = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_last = Step.new(:div,m_form_bot)
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'is true for m-form initial step divide by m-form-sum step' do
      m_form_top = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_first = Step.new(nil,m_form_top)
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      m_form_sum = Expression.new([step1,step2,step3,step4])
      step_last = Step.new(:div,m_form_sum)
      expression = Expression.new([step_first,step_last])
      expect(expression.is_rational?).to be true
    end

    it 'returns false if more than 2 steps' do
      expression = Expression.new([Step.new(nil,5),Step.new(:div,'x'),
        Step.new(:div,'x')])
      expect(expression.is_rational?).to be false
    end

    it 'returns false if more than second step is not divide' do
      expression = Expression.new([Step.new(nil,5),Step.new(:add,'x')])
      expect(expression.is_rational?).to be false
    end

    it 'returns false if more than second step is not right divide' do
      expression = Expression.new([Step.new(nil,5),Step.new(:div,'x',:lft)])
      expect(expression.is_rational?).to be false
    end

    it 'returns false if first step is not elementary or m-form' do
      expression = Expression.new([Step.new(nil,Expression.new([
        Step.new(:add,Expression.new())])),Step.new(:div,'x')])
      expect(expression.is_rational?).to be false
    end

    it 'returns false if last step is not elementary or m-form or m-form-sum' do
      step1 = Step.new(:add,6)
      step2 = Step.new(:sbt,'x')
      not_m_form_sum = Expression.new([Step.new(nil,Expression.new([]))])
      expression = Expression.new([Step.new(nil,2),Step.new(:div,not_m_form_sum)])
      expect(expression.is_rational?).to be false
    end
  end

  describe '#is_rational_sum' do
    it 'returns true for set of empty steps' do
      expression = Expression.new()
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns true for a sum of elementaries' do
      step1 = Step.new(nil,5)
      step2 = Step.new(:add,'x')
      expression = Expression.new([step1,step2])
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns true for a sum of m-forms' do
      exp1 = Expression.new([Step.new(nil,5),Step.new(:mtp,'x'),
        Step.new(:mtp,3),Step.new(:mtp,'y')])
      step1 = Step.new(nil,exp1)
      exp2 = Expression.new([Step.new(nil,5),Step.new(:mtp,7),
        Step.new(:mtp,'d'),Step.new(:mtp,'a')])
      step2 = Step.new(:sbt,exp2)
      expression = Expression.new([step1,step2])
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns true for a sum of elementaries and m-forms' do
      exp1 = Expression.new([Step.new(nil,5),Step.new(:mtp,'x'),
        Step.new(:mtp,3),Step.new(:mtp,'y')])
      step1 = Step.new(nil,exp1)
      exp2 = Expression.new([Step.new(nil,5),Step.new(:mtp,7),
        Step.new(:mtp,'d'),Step.new(:mtp,'a')])
      step2 = Step.new(:add,exp2)
      step3 = Step.new(:sbt,5)
      expression = Expression.new([step1,step2,step3])
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns true for a sum of rationals' do
      m_form_top = Expression.new([Step.new(nil,5),Step.new(:mtp,'x')])
      step_first = Step.new(nil,m_form_top)
      step1 = Step.new(nil,3)
      step2 = Step.new(:sbt,'x')
      step3 = Step.new(:add,Expression.new([Step.new(nil,5),Step.new(:mtp,'x')]))
      step4 = Step.new(:add,Expression.new([Step.new(nil,'y')]))
      m_form_sum = Expression.new([step1,step2,step3,step4])
      step_last = Step.new(:div,m_form_sum)
      rational1 = Expression.new([step_first,step_last])
      rational2_top = Step.new(nil,'x')
      rational2_bot = Step.new(:div,'y')
      rational2 = Expression.new([rational2_top,rational2_bot])
      expression = Expression.new([Step.new(nil,rational1),Step.new(:add,rational2)])
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns true for a sum of elementaries m-forms and rationals' do
      rational_top = Step.new(nil,'x')
      rational_bot = Step.new(:div,'y')
      rational = Expression.new([rational_top,rational_bot])
      rational_step = Step.new(nil,rational)
      elementary_step = Step.new(:add,5)
      m_form_step = Step.new(:sbt,Expression.new([Step.new(nil,3),Step.new(:mtp,'x')]))
      expression = Expression.new([rational_step,elementary_step,m_form_step])
      expect(expression.is_rational_sum?).to be true
    end

    it 'returns false for a sum involving a left addition' do
      rational_top = Step.new(nil,'x')
      rational_bot = Step.new(:div,'y')
      rational = Expression.new([rational_top,rational_bot])
      rational_step = Step.new(nil,rational)
      elementary_step = Step.new(:add,5,:lft)
      m_form_step = Step.new(:sbt,Expression.new([Step.new(nil,3),Step.new(:mtp,'x')]))
      expression = Expression.new([rational_step,elementary_step,m_form_step])
      expect(expression.is_rational_sum?).to be false
    end

    it 'returns false for a sum involving a left subtraction' do
      rational_top = Step.new(nil,'x')
      rational_bot = Step.new(:div,'y')
      rational = Expression.new([rational_top,rational_bot])
      rational_step = Step.new(nil,rational)
      elementary_step = Step.new(:add,5)
      m_form_step = Step.new(:sbt,Expression.new([Step.new(nil,3),Step.new(:mtp,'x')]),:lft)
      expression = Expression.new([rational_step,elementary_step,m_form_step])
      expect(expression.is_rational_sum?).to be false
    end
  end

  describe '#expand' do
    context 'with only right steps' do
      it 'is a mutator method which returns the object itself' do
        exp = expression_factory.build([[nil,5],[:add,'x']])
        expected_exp = expression_factory.build([[nil,5],[:add,'x']])
        expect(exp.expand.object_id).to eq exp.object_id
      end

      it 'expands an addition step' do
        exp = expression_factory.build([[nil,5],[:add,'x']])
        expected_exp = expression_factory.build([[nil,5],[:add,'x']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands 2 addition steps' do
        exp = expression_factory.build([[nil,5],[:add,'x'],[:add,'y']])
        expected_exp = expression_factory.build([[nil,5],[:add,'x'],[:add,'y']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands addition step whos value is an expression of additions steps' do
        exp = expression_factory.build([[nil,5],[:add,[[nil,7],[:add,'x']]],[:add,'y']])
        expected_exp = expression_factory.build([[nil,5],[:add,7],[:add,'x'],[:add,'y']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands subtraction steps' do
        exp = expression_factory.build([[nil,4],[:sbt,'x']])
        expected_exp = expression_factory.build([[nil,4],[:sbt,'x']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands e - (e + e) into e - e - e' do
        exp = expression_factory.build([[nil,4],[:sbt,[[nil,'x'],[:add,7]]]])
        expected_exp = expression_factory.build([[nil,4],[:sbt,'x'],[:sbt,7]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands e - (e - e + e) into e - e + e - e' do
        exp = expression_factory.build([[nil,4],[:sbt,[[nil,'x'],[:sbt,7],[:add,'y']]]])
        expected_exp = expression_factory.build([[nil,4],[:sbt,'x'],[:add,7],[:sbt,'y']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands e - (e - (e - e)) into e - e + e - e' do
        exp = expression_factory.build([[nil,4],[:sbt,[[nil,'x'],[:sbt,[[nil,5],[:sbt,'y']]]]]])
        expected_exp = expression_factory.build([[nil,4],[:sbt,'x'],[:add,5],[:sbt,'y']])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands e e into m' do
        exp = expression_factory.build([[nil,5],[:mtp,'z']])
        expected_exp = expression_factory.build([[nil,[[nil,5],[:mtp,'z']]]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands (e + e) e into m + m' do
        exp = expression_factory.build([[nil,4],[:add,'x'],[:mtp,5]])
        expected_exp = expression_factory.build([[nil,[[nil,4],[:mtp,5]]],
          [:add,[[nil,'x'],[:mtp,5]]]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands (e + m) e into m + m' do
        exp = expression_factory.build([[nil,4],[:add,[[nil,'x'],[:mtp,'y']]],[:mtp,5]])
        expected_exp = expression_factory.build([
          [nil,[[nil,4],[:mtp,5]]],[:add, [[nil,'x'],[:mtp,'y'],[:mtp,5]]]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands (e + m) m into m + m' do
        exp = expression_factory.build([[nil,4],[:add,[[nil,'x'],[:mtp,'y']]],
          [:mtp,[[nil,5],[:mtp,'z']]]])
        expected_exp = expression_factory.build([
          [nil,[[nil,4],[:mtp,5],[:mtp,'z']]],[:add, [[nil,'x'],[:mtp,'y'],[:mtp,5],[:mtp,'z']]]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands (e + e)(e - e) into m + m + m + m' do
        exp = expression_factory.build([[nil,4],[:add,'x'],[:mtp,[[nil,5],[:sbt,'y']]]])
        expected_exp = expression_factory.build([
          [nil,[[nil,4],[:mtp,5]]],[:add, [[nil,'x'],[:mtp,5]]],
          [:sbt, [[nil,4],[:mtp,'y']]],[:sbt, [[nil,'x'],[:mtp,'y']]]])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands (e - e)(e - e)(e + e)' do
        exp = expression_factory.build([
          [nil,[[nil,4],[:sbt,'x']]],
          [:mtp,[[nil,7],[:sbt,'y']]],
          [:mtp,[[nil,5],[:add,'z']]]
        ])
        expected_exp = expression_factory.build([
          [nil,[[nil,4],[:mtp,7],[:mtp,5]]],
          [:sbt,[[nil,'x'],[:mtp,7],[:mtp,5]]],
          [:sbt,[[nil,4],[:mtp,'y'],[:mtp,5]]],
          [:add,[[nil,'x'],[:mtp,'y'],[:mtp,5]]],
          [:add,[[nil,4],[:mtp,7],[:mtp,'z']]],
          [:sbt,[[nil,'x'],[:mtp,7],[:mtp,'z']]],
          [:sbt,[[nil,4],[:mtp,'y'],[:mtp,'z']]],
          [:add,[[nil,'x'],[:mtp,'y'],[:mtp,'z']]]
        ])
        expect(exp.expand).to eq expected_exp
      end

      it 'expands ((e - m)m - (e + m))(e - m)' do
        step_1 = step_factory.build([nil,[[nil,2],[:sbt,[[nil,3],[:mtp,'x']]]]])
        step_2 = step_factory.build([:mtp,[[nil,4],[:mtp,'y']]])
        step_3 = step_factory.build([:sbt,[[nil,5],[:add,[[nil,6],[:mtp,'z']]]]])
        step_4 = step_factory.build([:mtp,[[nil,7],[:sbt,[[nil,8],[:mtp,'w']]]]])
        exp = expression_factory.build([step_1,step_2,step_3,step_4])
        expected_exp = msum_factory.build([
            [nil,[2,4,'y',7]],        [:sbt,[3,'x',4,'y',7]],
            [:sbt,[5,7]],             [:sbt,[6,'z',7]],
            [:sbt,[2,4,'y',8,'w']],   [:add,[3,'x',4,'y',8,'w']],
            [:add,[5,8,'w']],         [:add,[6,'z',8,'w']]
          ])
        result = exp.expand
        expect(exp.expand).to eq expected_exp
      end
    end

    context 'with left steps' do
      it 'expands with left steps by converting them first' do
        exp = expression_factory.build([[nil,2],[:sbt,'x',:lft]])
        expected_exp = expression_factory.build([[nil,'x'],[:sbt,2]])
        result = exp.expand
        expect(exp.expand).to eq expected_exp
      end

      it 'expands two brackets which has left steps' do
        exp = expression_factory.build([[nil,[[nil,4],[:sbt,'x']]],[:mtp,[[nil,'x'],[:add,3]],:lft]])
        expected_exp = msum_factory.build([[nil,['x',4]],[:add,[3,4]],[:sbt,['x','x']],[:sbt,[3,'x']]])
        result = exp.expand
        expect(exp.expand).to eq expected_exp
      end

      it 'expands ((e - m)m - (e + m))(e - m) with left steps' do
        step_4 = step_factory.build([nil,[[nil,7],[:sbt,[[nil,8],[:mtp,'w']]]]])
        step_1 = step_factory.build([nil,[[nil,2],[:sbt,[[nil,3],[:mtp,'x']]]]])
        step_2 = step_factory.build([:mtp,[[nil,4],[:mtp,'y']]])
        step_3 = step_factory.build([:sbt,[[nil,5],[:add,[[nil,6],[:mtp,'z']]]]])
        lft_exp = expression_factory.build([step_1,step_2,step_3])
        lft_step = step_factory.build([:mtp,lft_exp,:lft])
        exp = expression_factory.build([step_4,lft_step])
        expected_exp = msum_factory.build([
            [nil,[2,4,'y',7]],        [:sbt,[3,'x',4,'y',7]],
            [:sbt,[5,7]],             [:sbt,[6,'z',7]],
            [:sbt,[2,4,'y',8,'w']],   [:add,[3,'x',4,'y',8,'w']],
            [:add,[5,8,'w']],         [:add,[6,'z',8,'w']]
          ])
        result = exp.expand
        expect(exp.expand).to eq expected_exp
      end

      it 'expands ((e - m)m - (e + m))(e - m) with deep left steps' do
        step_4 = step_factory.build([nil,[[nil,[[nil,'w'],[:mtp,8,:lft]]],[:sbt,7,:lft]]])
        step_1 = step_factory.build([nil,[[nil,2],[:sbt,[[nil,3],[:mtp,'x']]]]])
        step_2 = step_factory.build([:mtp,[[nil,4],[:mtp,'y']]])
        step_3 = step_factory.build([:sbt,[[nil,5],[:add,[[nil,6],[:mtp,'z']]]]])
        lft_exp = expression_factory.build([step_1,step_2,step_3])
        lft_step = step_factory.build([:mtp,lft_exp,:lft])
        exp = expression_factory.build([step_4,lft_step])
        expected_exp = msum_factory.build([
            [nil,[2,4,'y',7]],        [:sbt,[3,'x',4,'y',7]],
            [:sbt,[5,7]],             [:sbt,[6,'z',7]],
            [:sbt,[2,4,'y',8,'w']],   [:add,[3,'x',4,'y',8,'w']],
            [:add,[5,8,'w']],         [:add,[6,'z',8,'w']]
          ])
        result = exp.expand
        expect(result).to eq expected_exp
      end
    end
  end

  describe '#rsum_mtp_rsum' do
    it '(r) x (r) into a new rsum' do
      r_1 = [[5], [[nil,[2,'x']]]]
      r_sum_conf_1 = [[nil,r_1]]
      r_2 = [['a'], [[nil,['y','z']]]]
      r_sum_conf_2 = [[nil,r_2]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      r_sum_2 = rsum_factory.build(r_sum_conf_2)
      expected_result_conf = [[5,'a'], [[nil,[2,'x','y','z']]]]
      expected_result = rsum_factory.build([[nil,expected_result_conf]])
      expect(r_sum_1.rsum_mtp_rsum(r_sum_2)).to eq expected_result
    end

    it 'rsum_mtp_rsum is a mutator method' do
      r_1 = [[5], [[nil,[2,'x']]]]
      r_sum_conf_1 = [[nil,r_1]]
      r_2 = [['a'], [[nil,['y','z']]]]
      r_sum_conf_2 = [[nil,r_2]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      r_sum_2 = rsum_factory.build(r_sum_conf_2)
      result = r_sum_1.rsum_mtp_rsum(r_sum_2)
      expected_result_conf = [[5,'a'], [[nil,[2,'x','y','z']]]]
      expected_result = rsum_factory.build([[nil,expected_result_conf]])
      expect(result.object_id).to eq r_sum_1.object_id
      expect(r_sum_1).to eq expected_result
    end

    it '(r + r) x (r) into a new rsum' do
      r_1_1 = [[5], [[nil,[2,'x']]]]
      r_1_2 = [[7], [[nil,[8,'a']],[:sbt,[6,'b']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2]]
      r_2 = [['a'], [[nil,['y','z']]]]
      r_sum_conf_2 = [[nil,r_2]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      r_sum_2 = rsum_factory.build(r_sum_conf_2)
      expected_result_conf_1 = [[5,'a'], [[nil,[2,'x','y','z']]]]
      expected_result_conf_2 = [[7,'a'], [[nil,[8,'a','y','z']],
        [:sbt,[6,'b','y','z']]]]
      expected_result = rsum_factory.build([
        [nil,expected_result_conf_1],
        [:sbt,expected_result_conf_2]
      ])
      result = r_sum_1.rsum_mtp_rsum(r_sum_2)
      expect(result).to eq expected_result
    end

    it '(r + r) x (r - r) into new rsum' do
      r_1_1 = [[5], [[nil,[2,'x']]]]
      r_1_2 = [[7], [[nil,[8,'a']],[:sbt,[6,'b']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2]]
      r_2_1 = [[7], [[nil,[9]],[:add,['c','d']]]]
      r_2_2 = [['a'], [[nil,['y','z']]]]
      r_sum_conf_2 = [[nil,r_2_1],[:add,r_2_2]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      r_sum_2 = rsum_factory.build(r_sum_conf_2)
      expected_result_conf_1 = [[5,7], [[nil,[2,'x',9]],[:add,[2,'x','c','d']]]]
      expected_result_conf_2 = [[7,7], [[nil,[8,'a',9]],[:sbt,[6,'b',9]],
        [:add,[8,'a','c','d']],[:sbt,[6,'b','c','d']]]]
      expected_result_conf_3 = [[5,'a'], [[nil,[2,'x','y','z']]]]
      expected_result_conf_4 = [[7,'a'], [[nil,[8,'a','y','z']],
        [:sbt,[6,'b','y','z']]]]
      expected_result = rsum_factory.build([
        [nil,expected_result_conf_1],
        [:sbt,expected_result_conf_2],
        [:add,expected_result_conf_3],
        [:sbt,expected_result_conf_4]
      ])
      result = r_sum_1.rsum_mtp_rsum(r_sum_2)
      expect(result).to eq expected_result
    end
  end

  describe '#rsum_to_rational' do
    it 'does this work for x/1?' do
      r_1_1 = [['x'], [[nil,[1]]]]
      r_sum_conf_1 = [[nil,r_1_1]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      numerator_exp_config = [[nil,['x']]]
      denominator_exp_config = [[nil,[1]]]
      nrator = msum_factory.build(numerator_exp_config)
      dnator = msum_factory.build(denominator_exp_config)
      expected_exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      result = r_sum_1.rsum_to_rational
      expect(r_sum_1).to eq expected_exp
    end

    it 'sum terms in a 1 term rsum into a rational' do
      r_1_1 = [[5], [[nil,[2,'x']]]]
      r_sum_conf_1 = [[nil,r_1_1]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      numerator_exp_config = [[nil,[5]]]
      denominator_exp_config = [[nil,[2,'x']]]
      nrator = msum_factory.build(numerator_exp_config)
      dnator = msum_factory.build(denominator_exp_config)
      expected_exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      result = r_sum_1.rsum_to_rational
      expect(result).to eq expected_exp
    end

    it 'sum terms in a 2 term rsum into a rational' do
      r_1_1 = [[5], [[nil,[2,'x']]]]
      r_1_2 = [[7], [[nil,[8,'a']],[:sbt,[6,'b']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      numerator_exp_config = [[nil,[5,8,'a']],[:sbt,[5,6,'b']],[:sbt,[7,2,'x']]]
      denominator_exp_config = [[nil,[2,'x',8,'a']],[:sbt,[2,'x',6,'b']]]
      nrator = msum_factory.build(numerator_exp_config)
      dnator = msum_factory.build(denominator_exp_config)
      expected_exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      expect(r_sum_1.rsum_to_rational).to eq expected_exp
    end

    it 'sum terms in a 3 term rsum into a rational' do
      r_1_1 = [[5], [[nil,[2,'x']]]]
      r_1_2 = [[7], [[nil,[8,'a']],[:sbt,[6,'b']]]]
      r_1_3 = [[9], [[nil,['n']],[:add,['m']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2],[:add,r_1_3]]
      r_sum_1 = rsum_factory.build(r_sum_conf_1)
      numerator_exp_config = [[nil,[5,8,'a','n']],[:sbt,[5,6,'b','n']],
        [:sbt,[7,2,'x','n']],[:add,[5,8,'a','m']],[:sbt,[5,6,'b','m']],
        [:sbt,[7,2,'x','m']],[:add,[9,2,'x',8,'a']],[:sbt,[9,2,'x',6,'b']]
      ]
      denominator_exp_config = [[nil,[2,'x',8,'a','n']],[:sbt,[2,'x',6,'b','n']],
      [:add,[2,'x',8,'a','m']],[:sbt,[2,'x',6,'b','m']]]
      nrator = msum_factory.build(numerator_exp_config)
      dnator = msum_factory.build(denominator_exp_config)
      expected_exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      result = r_sum_1.rsum_to_rational
      expect(result).to eq expected_exp
    end
  end

  describe '#rational_to_rsum' do
    it 'split a suitable rational to 1 term rsum' do
      nrator = msum_factory.build([[nil,[8,'a']]])
      dnator = msum_factory.build([[nil,[3,'x']],[:add,[4,'y']]])
      exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      r_1_1 = [[8,'a'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_sum_conf_1 = [[nil,r_1_1]]
      expected_r_sum = rsum_factory.build(r_sum_conf_1)
      result = exp.rational_to_rsum
      expect(result).to eq expected_r_sum
    end

    it 'is a mutator method' do
      nrator = msum_factory.build([[nil,[8,'a']]])
      dnator = msum_factory.build([[nil,[3,'x']],[:add,[4,'y']]])
      exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      r_1_1 = [[8,'a'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_sum_conf_1 = [[nil,r_1_1]]
      expected_r_sum = rsum_factory.build(r_sum_conf_1)
      result = exp.rational_to_rsum
      expect(result.object_id).to eq exp.object_id
      expect(exp).to eq expected_r_sum
    end

    it 'split a suitable rational to 2 term rsum' do
      nrator = msum_factory.build([[nil,[8,'a']],[:sbt,[6,'b']]])
      dnator = msum_factory.build([[nil,[3,'x']],[:add,[4,'y']]])
      exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      r_1_1 = [[8,'a'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_1_2 = [[6,'b'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2]]
      expected_r_sum = rsum_factory.build(r_sum_conf_1)
      result = exp.rational_to_rsum
      expect(result).to eq expected_r_sum
    end

    it 'split a suitable rational to 3 term rsum' do
      nrator = msum_factory.build([[nil,[8,'a']],[:sbt,[6,'b']],[:add,[11,'z']]])
      dnator = msum_factory.build([[nil,[3,'x']],[:add,[4,'y']]])
      exp = expression_factory.build([[nil,nrator],[:div,dnator]])
      r_1_1 = [[8,'a'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_1_2 = [[6,'b'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_1_3 = [[11,'z'],[[nil,[3,'x']],[:add,[4,'y']]]]
      r_sum_conf_1 = [[nil,r_1_1],[:sbt,r_1_2],[:add,r_1_3]]
      expected_r_sum = rsum_factory.build(r_sum_conf_1)
      result = exp.rational_to_rsum
      expect(result).to eq expected_r_sum
    end
  end

  describe '#flatten' do
    it 'flattens a one layer of exp step exp wrapping' do
      exp = expression_factory.build([[nil,[[nil,5]]]])
      expected_exp = expression_factory.build([[nil,5]])
      expect(exp.flatten).to eq expected_exp
    end

    it 'flattens a one layer wrapping of two steps' do
      exp = expression_factory.build([[nil,[[nil,5],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,5],[:mtp,'x']])
      expect(exp.flatten).to eq expected_exp
    end

    it 'flattens a 2 layer of exp step exp wrapping' do
      exp = expression_factory.build([[nil,[[nil,[[nil,5]]]]]])
      expected_exp = expression_factory.build([[nil,5]])
      expect(exp.flatten).to eq expected_exp
    end

    it 'flattens a 4 layer of exp step exp wrapping' do
      exp = expression_factory.build([[nil,[[nil,[[nil,[[nil,[[nil,5]]]]]]]]]])
      expected_exp = expression_factory.build([[nil,5]])
      expect(exp.flatten).to eq expected_exp
    end


    it 'flattens layers of wrapping recursively eg 1' do
      exp = expression_factory.build([[nil,[[nil,'x'], [:add,[[nil,
        [[nil,5]]]]]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,5]])
      expect(exp.flatten).to eq expected_exp
    end

    it 'flattens layers of wrapping recursively eg 2' do
      exp = expression_factory.build([[nil,[[nil,'x'], [:add,[[nil,[[nil,5],
        [:mtp,'y']]]]]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,[[nil,5],[:mtp,'y']]]])
      expect(exp.flatten).to eq expected_exp
    end

    it 'flattens layers of wrapping recursively eg 3' do
      exp = expression_factory.build([[nil,[[nil,'x'], [:add,[[nil,[[nil,5],
        [:mtp,[[nil,[[nil,'y']]]]]]]]]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add, [[nil,5],
        [:mtp,'y']]]])
      result = exp.flatten
      expect(result).to eq expected_exp
    end

    it 'flattens is a mutator method that modifies and returns self' do
      exp = expression_factory.build([[nil,[[nil,'x'], [:add,[[nil,[[nil,5],
        [:mtp,[[nil,[[nil,'y']]]]]]]]]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add, [[nil,5],[:mtp,
        [[nil,'y']]]]]])
      result = exp.flatten
      expect(exp.object_id).to eq result.object_id
    end

    it 'flattens the second term of an exp with flatten being a mutator' do
      exp = expression_factory.build([[nil,7],[:mtp,[[nil,[[nil,'x']]]]]])
      expected_exp = expression_factory.build([[nil,7],[:mtp,[[nil,'x']]]])
      result = exp.flatten
      expect(exp.steps.last.val.object_id).to eq result.steps.last.val.object_id
    end

    it 'flattens a non-nil step with a nil step value' do
      exp = expression_factory.build([[nil,'x'],[:add,[[nil,7]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,7]])
      result = exp.flatten
      expect(result).to eq expected_exp
    end

    it 'flattens a mid terms recursively 2 layers' do
      exp = expression_factory.build([[nil,'x'],[:mtp,[[nil,5], [:add,[[nil,7]]] ]]])
      expected_exp = expression_factory.build([[nil,'x'],[:mtp,[[nil,5], [:add,7] ]]])
      result = exp.flatten
      expect(result).to eq expected_exp
    end

    it 'flattens a mid terms recursively 3 layers' do
      exp = expression_factory.build([[nil,'x'],[:mtp,[[nil,5], [:add,[[nil,7],[:div,[[nil,'y']]]]] ]]])
      expected_exp = expression_factory.build([[nil,'x'],[:mtp,[[nil,5], [:add,[[nil,7],[:div,'y']]] ]]])
      result = exp.flatten
      expect(result).to eq expected_exp
    end
  end

  describe '#latex' do
    context 'no left step, no x sign' do
      it 'produce an empty string for empty exp' do
        exp = expression_factory.build([])
        expect(exp.latex).to eq ''
      end

      it 'produce latex for a single nil numerical e step' do
        exp = expression_factory.build([[nil,2]])
        expect(exp.latex).to eq '2'
      end

      it 'produce latex for a single nil string value e step' do
        exp = expression_factory.build([[nil,'x']])
        expect(exp.latex).to eq 'x'
      end

      it 'produce latex for e + e' do
        exp = expression_factory.build([[nil,'x'],[:add,3]])
        expect(exp.latex).to eq 'x+3'
      end

      it 'produce latex for e - e' do
        exp = expression_factory.build([[nil,'x'],[:sbt,3]])
        expect(exp.latex).to eq 'x-3'
      end

      it 'produce latex for e - e + e' do
        exp = expression_factory.build([[nil,'x'],[:sbt,3],[:add,'y']])
        expect(exp.latex).to eq 'x-3+y'
      end

      it 'produce latex for e + (e - e)' do
        exp = expression_factory.build([[nil,'x'],[:add,[[nil,5],[:sbt,'y']]]])
        expect(exp.latex).to eq 'x+\left(5-y\right)'
      end

      it 'produce latex for e - (e - e)' do
        exp = expression_factory.build([[nil,'x'],[:sbt,[[nil,5],[:sbt,'y']]]])
        expect(exp.latex).to eq 'x-\left(5-y\right)'
      end

      it 'produce latex for (e - e) + e' do
        exp = expression_factory.build([[nil,[[nil,5],[:sbt,'y']]],[:add,'x']])
        expect(exp.latex).to eq '5-y+x'
      end

      it 'produce latex for (e - e) x e' do
        exp = expression_factory.build([[nil,5],[:sbt,'y'],[:mtp,'x']])
        expect(exp.latex).to eq '\left(5-y\right)x'
      end

      it 'produce latex for (e - e)(e + e)' do
        exp = expression_factory.build([[nil,5],[:sbt,'y'],[:mtp,[[nil,3],[:add,'x']]]])
        expect(exp.latex).to eq '\left(5-y\right)\left(3+x\right)'
      end

      it 'produce latex for (e - e)m' do
        exp = expression_factory.build([[nil,5],[:sbt,'y'],[:mtp,[[nil,3],[:mtp,'x']]]])
        expect(exp.latex).to eq '\left(5-y\right)3x'
      end

      it 'produce latex for (e - e) x large m' do
        exp = expression_factory.build([[nil,5],[:sbt,'y'],[:mtp,[[nil,3],[:mtp,'x'],[:mtp,'z']]]])
        expect(exp.latex).to eq '\left(5-y\right)3xz'
      end

      it 'produce latex for ((e - m)m - (e + m))(e - m)' do
        step_1_1 = step_factory.build([nil,2])
        step_1_2 = step_factory.build([:sbt,[[nil,3],[:mtp,'x']]])
        step_2 = step_factory.build([:mtp,[[nil,4],[:mtp,'y']]])
        step_3 = step_factory.build([:sbt,[[nil,5],[:add,[[nil,6],[:mtp,'z']]]]])
        step_4 = step_factory.build([:mtp,[[nil,7],[:sbt,[[nil,8],[:mtp,'w']]]]])
        exp = expression_factory.build([step_1_1,step_1_2,step_2,step_3,step_4])
        expected_latex = "\\left(\\left(2-3x\\right)4y-\\left(5+6z\\right)\\righ"\
          "t)\\left(7-8w\\right)"
        expect(exp.latex).to eq expected_latex
      end

      it 'produce latex for (m + m - m) e m' do
        exp = expression_factory.build([[nil, [[nil,5],[:mtp,'x']]  ],
          [:add, [[nil,2],[:mtp,'y']] ],[:sbt, [[nil,3],[:mtp,'z']] ],
          [:mtp,'a'],[:mtp, [[nil,4],[:mtp,'w']] ]])
        expected_latex = "\\left(5x+2y-3z\\right)a4w"
        expect(exp.latex).to eq expected_latex
      end

      it 'produce latex for ((m + e - m) + e - (m + e))e m' do
        msum_exp = msum_factory.build([[nil,[2,'a']],[:sbt,[3]],[:add,[4,'b','c']]])
        step_1 = step_factory.build([nil,msum_exp])
        step_2 = step_factory.build([:add,5])
        msum_exp_2 = msum_factory.build([[nil,[6,'d']],[:sbt,['e']]])
        step_3 = step_factory.build([:sbt,msum_exp_2])
        step_4 = step_factory.build([:mtp,7])
        step_5 = step_factory.build([:mtp,[[nil,[[nil,'x'],[:mtp,'y']]]]])
        exp = expression_factory.build([step_1,step_2,step_3,step_4,step_5])
        expected_latex = '\left(2a-3+4bc+5-\left(6d-e\right)\right)7xy'
        expect(exp.latex).to eq expected_latex
      end

      it 'produce latex for e/e' do
        exp = expression_factory.build([[nil,'x'],[:div,5]])
        expect(exp.latex).to eq '\frac{x}{5}'
      end

      it 'produce latex for e/e - e' do
        exp = expression_factory.build([[nil,'x'],[:div,5],[:sbt,'y']])
        expect(exp.latex).to eq '\frac{x}{5}-y'
      end

      it 'produce latex for m/(e - e) + m' do
        exp = expression_factory.build([[nil,[[nil,2],[:mtp,'x']]],
          [:div,[[nil,3],[:sbt,'w']]],[:add,[[nil,'a'],[:mtp,'b']]]])
        expect(exp.latex).to eq '\frac{2x}{3-w}+ab'
      end

      it 'produce latex for m/(e - e) + e/e' do
        exp = expression_factory.build([[nil,[[nil,2],[:mtp,'x']]],
          [:div,[[nil,3],[:sbt,'w']]],[:add,[[nil,'a'],[:div,'b']]]])
        expect(exp.latex).to eq '\frac{2x}{3-w}+\frac{a}{b}'
      end

      it 'produce latex for (m/(e - e) + e/e)m - e/e' do
        exp = expression_factory.build([[nil,[[nil,2],[:mtp,'x']]],
          [:div,[[nil,3],[:sbt,'w']]],[:add,[[nil,'a'],[:div,'b']]],
          [:mtp,[[nil,4],[:mtp,'c']]],[:sbt,[[nil,11],[:div,'f']]]])
        expected_latex = '\left(\frac{2x}{3-w}+\frac{a}{b}\right)4c-\frac{11}{f}'
        expect(exp.latex).to eq expected_latex
      end

      it 'produce latex for (((m/e + m - e) e + m) / (e-m) + m)(e / m-m + e)' do
        step_1 = step_factory.build([nil,[[nil,[[nil,2],[:mtp,'a']]],[:div,3],
          [:add,[[nil,4],[:mtp,'b']]],[:sbt,'c']]])
        step_2 = step_factory.build([:mtp,5])
        step_3 = step_factory.build([:add,[[nil,6],[:mtp,'d']]])
        step_4 = step_factory.build([:div,[[nil,6],[:sbt, [[nil,[[nil,7],[:mtp,'e']]]]        ]]])
        step_5 = step_factory.build([:add,[[nil,8],[:mtp,'f']]])
        step_6 = step_factory.build([:mtp,[[nil,9],[:div,  [[nil,
          [[nil,10],[:mtp,'x']]],[:sbt,[[nil,11],[:mtp,'y']]]]],[:add,12]]])
        exp = expression_factory.build([step_1,step_2,step_3,step_4,step_5,step_6])
        expected_latex = '\left(\frac{\left(\frac{2a}{3}+4b-c\right)5+6d}{6-7e}+8f\right)\left(\frac{9}{10x-11y}+12\right)'
        expect(exp.latex).to eq expected_latex
      end
    end

    context 'with left steps' do
      it 'produce latex for e - e with left step' do
        exp = expression_factory.build([[nil,5],[:sbt,'y',:lft]])
         expect(exp.latex).to eq 'y-5'
      end

      it 'produce latex for (e - e)m with 2 left steps' do
        exp = expression_factory.build([[nil,'y'],[:sbt,'5',:lft],[:mtp,[[nil,'x'],[:mtp,3,:lft]]]])
        expect(exp.latex).to eq '\left(5-y\right)3x'
      end

      it 'produce latex for complex expression with left steps recurisively' do
        step_1_1 = step_factory.build([nil,2])
        step_1_2 = step_factory.build([:sbt,[[nil,3],[:mtp,'x']]])
        step_2 = step_factory.build([:mtp,[[nil,4],[:mtp,'y']]])
        step_3 = step_factory.build([:sbt,[[nil,5],[:add,[[nil,'z'],[:mtp,6,:lft]]]]])
        step_4 = step_factory.build([:mtp,[[nil,7],[:sbt,[[nil,8],[:mtp,'w']]]]])
        step_4 = step_factory.build([:mtp,[[nil,[[nil,8],[:mtp,'w']]],[:sbt,7,:lft]]])
        exp = expression_factory.build([step_1_1,step_1_2,step_2,step_3,step_4])
        expected_latex = "\\left(\\left(2-3x\\right)4y-\\left(5+6z\\right)\\righ"\
          "t)\\left(7-8w\\right)"
        expect(exp.latex).to eq expected_latex
      end
    end

    context 'adding x sign between numerical mtp steps' do
      it 'produce latex for e x e for 2 numerical steps' do
        exp = expression_factory.build([[nil,3],[:mtp,4]])
        expect(exp.latex).to eq '3\times4'
      end

      it 'produce latex for e x e x e where last 2 steps are numerical' do
        exp = expression_factory.build([[nil,'y'],[:mtp,3],[:mtp,4]])
        expect(exp.latex).to eq 'y3\times4'
      end

      it 'produce latex a monster expression with consecutive mtp num steps' do
        step_1 = step_factory.build([nil,[[nil,[[nil,2],[:mtp,'a']]],[:div,3],
          [:add,[[nil,4],[:mtp,'b']]],[:sbt,'c']]])
        step_2 = step_factory.build([:mtp,5])
        step_3 = step_factory.build([:add,[[nil,6],[:mtp,'d']]])
        step_4 = step_factory.build([:div,[[nil,6],[:sbt, [[nil,[[nil,7],[:mtp,21]]]]        ]]])
        step_5 = step_factory.build([:add,[[nil,8],[:mtp,'f']]])
        step_6 = step_factory.build([:mtp,[[nil,9],[:div,  [[nil,
          [[nil,10],[:mtp,'x']]],[:sbt,[[nil,11],[:mtp,31]]]]],[:add,12]]])
        exp = expression_factory.build([step_1,step_2,step_3,step_4,step_5,step_6])
        expected_latex = '\left(\frac{\left(\frac{2a}{3}+4b-c\right)5+6d}{6-7\times21}+8f\right)\left(\frac{9}{10x-11\times31}+12\right)'
        expect(exp.latex).to eq expected_latex
      end
    end
  end

  describe '#expand_to_rsum' do
    it 'expands an e step to a rsum' do
      exp = expression_factory.build([[nil,5]])
      r_conf = [[5], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf]]
      expected_exp = rsum_factory.build(r_sum_conf)
      expect(exp.expand_to_rsum).to eq expected_exp
    end

    it 'expands e + e to a rsum' do
      exp = expression_factory.build([[nil,5],[:add,'x']])
      r_conf_1 = [[5], [[nil,[1]]]]
      r_conf_2 = [['x'], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands an unflattend e step exp' do
      exp = expression_factory.build([[nil,[[nil,5],[:add,'x']]]])
      r_conf_1 = [[5], [[nil,[1]]]]
      r_conf_2 = [['x'], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      expect(exp.expand_to_rsum).to eq expected_exp
    end

    it 'expands a 2 layer unflattend e step exp' do
      exp = expression_factory.build([[nil,[[nil,[[nil,5]]]]]])
      r_conf = [[5], [ [nil,[1]] ]]
      r_sum_conf = [[nil,r_conf]]
      expected_exp = rsum_factory.build(r_sum_conf)
      expect(exp.expand_to_rsum).to eq expected_exp
    end

    it 'expands an m step to a rsum' do
      exp = expression_factory.build([[nil,[[nil,5],[:mtp,'x']] ]])
      r_conf = [[5,'x'], [ [nil,[1]] ]]
      r_sum_conf = [[nil,r_conf]]
      expected_exp = rsum_factory.build(r_sum_conf)
      expect(exp.expand_to_rsum).to eq expected_exp
    end

    it 'expands_to_rsum is a mutator method' do
      exp = expression_factory.build([[nil,[[nil,5],[:mtp,'x']] ]])
      r_conf = [[5,'x'], [ [nil,[1]] ]]
      r_sum_conf = [[nil,r_conf]]
      expected_exp = rsum_factory.build(r_sum_conf)
      exp.expand_to_rsum
      expect(exp).to eq expected_exp
    end

    it 'expands_to_rsum is a mutator method that returns self' do
      exp = expression_factory.build([[nil,[[nil,5],[:mtp,'x']] ]])
      r_conf = [[5,'x'], [ [nil,[1]] ]]
      r_sum_conf = [[nil,r_conf]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(exp.object_id).to eq result.object_id
    end

    it 'expands (r) exp into itself (r) - no change' do
      r_conf = [[3], [ [nil,['x']] ]]
      r_sum_conf = [[nil,r_conf]]
      exp = rsum_factory.build(r_sum_conf)
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands (e + e) m exp into r + r' do
      exp = expression_factory.build([[nil,3],[:add,'x'],[:mtp,[[nil,2],[:mtp,'y']]]])
      r_conf_1 = [[3,2,'y'], [[nil,[1]]]]
      r_conf_2 = [['x',2,'y'], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands (e + e) m exp into r + r' do
      exp = expression_factory.build([[nil,3],[:add,'x'],[:div,[[nil,2],[:mtp,'y']]]])
      r_conf_1 = [[3], [[nil,[2,'y']]]]
      r_conf_2 = [['x'], [[nil,[2,'y']]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands (e + e) / r exp into r + r' do
      exp = expression_factory.build([[nil,3],[:add,'x'],[:div,[[nil,2],[:div,'y']]]])
      r_conf_1 = [[3,'y'], [[nil,[2]]]]
      r_conf_2 = [['x','y'], [[nil,[2]]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands ((e + e)/(e + e) exp into r + r' do
      exp = expression_factory.build([[nil,3],[:add,'x'],[:div,[[nil,2],[:add,'y']]]])
      r_conf_1 = [[3], [[nil,[2]],[:add,['y']]]]
      r_conf_2 = [['x'], [[nil,[2]],[:add,['y']]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands (((e + e)/(r + e) + (e + m))(e + r) exp into r + r + r + r' do
      r_1 = rational_factory.build([[4],[[nil,['b']],[:add,['a']]]])
      exp = expression_factory.build([[nil,2],[:add,'x'],[:div,[[nil,r_1],
        [:add,'y']]]])
      r_conf_1 = [[2,'b'], [[nil,[4]],[:add,['y','b']],[:add,['y','a']]]]
      r_conf_2 = [['x','b'], [[nil,[4]],[:add,['y','b']],[:add,['y','a']]]]
      r_conf_3 = [[2,'a'], [[nil,[4]],[:add,['y','b']],[:add,['y','a']]]]
      r_conf_4 = [['x','a'], [[nil,[4]],[:add,['y','b']],[:add,['y','a']]]]
      r_sum_conf = [[nil,r_conf_1],[:add,r_conf_2],
        [:add,r_conf_3],[:add,r_conf_4]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands some crazy stuff correctly!' do
      r_1 = rational_factory.build([[4],[[nil,['b']]]])
      r_2 = rational_factory.build([['e'],[[nil,['f']]]])
      r_3 = rational_factory.build([['p'],[[nil,['q']]]])
      exp = expression_factory.build([[nil,2],[:add,'x'],
        [:div,[[nil,r_1],[:add,'y'],[:div,r_2]]],
        [:add,[[nil,'c'],[:add,5]]],
        [:mtp,[[nil,6],[:add,r_3]]]
      ])
      r_conf_1 = [[2,'b','e','e',6], [[nil,[4,'f','e']],[:add,['y','f','b','e']]]]
      r_conf_2 = [['x','b','e','e',6], [[nil,[4,'f','e']],[:add,['y','f','b','e']]]]
      r_conf_3 = [['c',6], [[nil,[1]]]]
      r_conf_4 = [[5,6], [[nil,[1]]]]
      r_conf_5 = [[2,'b','e','e','p'], [[nil,[4,'f','e','q']],[:add,['y','f','b','e','q']]]]
      r_conf_6 = [['x','b','e','e','p'], [[nil,[4,'f','e','q']],[:add,['y','f','b','e','q']]]]
      r_conf_7 = [['c','p'], [[nil,['q']]]]
      r_conf_8 = [[5,'p'], [[nil,['q']]]]
      r_sum_conf = [    [nil,r_conf_1], [:add,r_conf_2],[:add,r_conf_3],
        [:add,r_conf_4],[:add,r_conf_5],[:add,r_conf_6],[:add,r_conf_7],
        [:add,r_conf_8]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expand e - e' do
      exp = expression_factory.build([[nil,2],[:sbt,'x']])
      r_conf_1 = [[2], [[nil,[1]]]]
      r_conf_2 = [['x'], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf_1],[:sbt,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expand e - (e + e)' do
      exp = expression_factory.build([[nil,2],[:sbt,[[nil,'x'],[:add,'y']]]])
      r_conf_1 = [[2], [[nil,[1]]]]
      r_conf_2 = [['x'], [[nil,[1]]]]
      r_conf_3 = [['y'], [[nil,[1]]]]
      r_sum_conf = [[nil,r_conf_1],[:sbt,r_conf_2],[:sbt,r_conf_3]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands ((e - e)/(e - e) exp into r + r' do
      exp = expression_factory.build([[nil,3],[:sbt,'x'],[:div,[[nil,2],
        [:sbt,'y']]]])
      r_conf_1 = [[3], [[nil,[2]],[:sbt,['y']]]]
      r_conf_2 = [['x'], [[nil,[2]],[:sbt,['y']]]]
      r_sum_conf = [[nil,r_conf_1],[:sbt,r_conf_2]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end

    it 'expands (((e - e)/(r - e) exp into r - r - r + r' do
      r_1 = rational_factory.build([[4],[[nil,['b']],[:sbt,['a']]]])
      exp = expression_factory.build([[nil,2],[:sbt,'x'],[:div,[[nil,r_1],
        [:sbt,'y']]]])
      r_conf_1 = [[2,'b'], [[nil,[4]],[:sbt,['y','b']],[:add,['y','a']]]]
      r_conf_2 = [['x','b'], [[nil,[4]],[:sbt,['y','b']],[:add,['y','a']]]]
      r_conf_3 = [[2,'a'], [[nil,[4]],[:sbt,['y','b']],[:add,['y','a']]]]
      r_conf_4 = [['x','a'], [[nil,[4]],[:sbt,['y','b']],[:add,['y','a']]]]
      r_sum_conf = [[nil,r_conf_1],[:sbt,r_conf_2],
        [:sbt,r_conf_3],[:add,r_conf_4]]
      expected_exp = rsum_factory.build(r_sum_conf)
      result = exp.expand_to_rsum
      expect(result).to eq expected_exp
    end
  end

  describe '#modify_add_mtp_dir_to_rgt' do
    it 'modifies all left add mtp steps to right steps' do
      exp = expression_factory.build([[:add,5,:lft],[:mtp,'x',:lft],
        [:add,6,:lft],[:mtp,'y',:lft]])
      expected_exp = expression_factory.build([[:add,5],[:mtp,'x'],[:add,6],
        [:mtp,'y']])
      expect(exp.modify_add_mtp_dir_to_rgt).to eq expected_exp
    end

    it 'modify_add_mtp_dir_to_rgt is a mutator method' do
      exp = expression_factory.build([[:add,5,:lft],[:mtp,'x',:lft],
        [:add,6,:lft],[:mtp,'y',:lft]])
      expected_exp = expression_factory.build([[:add,5],[:mtp,'x'],[:add,6],
        [:mtp,'y']])
      result = exp.modify_add_mtp_dir_to_rgt
      expect(exp).to eq expected_exp
      expect(result.object_id).to eq exp.object_id
    end


    it 'converts multi-layered lft add mtp steps recursively' do
      exp = expression_factory.build([[:add,5,:lft],[:add,[[nil,7],[:mtp,
        [[nil,6],[:add,'y',:lft],[:mtp,'z',:lft]],:lft]],:lft]])
      expected_exp = expression_factory.build([[:add,5],[:add,[[nil,7],[:mtp,
        [[nil,6],[:add,'y'],[:mtp,'z']]]]]])
      expect(exp.modify_add_mtp_dir_to_rgt).to eq expected_exp
    end
  end

  describe '#convert_lft_steps' do
    it 'converts (b) (add,a,lft) to b (add,b)' do
      exp = expression_factory.build([[nil,5],[:add,'x',:lft]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,5]])
      expect(exp.convert_lft_steps).to eq expected_exp
    end

    it 'convert_lft_steps is a mutator method' do
      exp = expression_factory.build([[nil,5],[:add,'x',:lft]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,5]])
      result = exp.convert_lft_steps
      expect(exp).to eq expected_exp
      expect(result.object_id).to eq exp.object_id
    end

    it 'converts a - (b + c) so there are no lft steps' do
      exp = expression_factory.build([[nil,'b'],[:add,'c'],[:sbt,'a',:lft]])
      expected_exp = expression_factory.build([[nil,'a'],[:sbt,[[nil,'b'],
        [:add,'c']]]])
      expect(exp.convert_lft_steps).to eq expected_exp
    end

    it 'converts d / (a - (b + c)) so there are no lft steps recursively' do
      exp = expression_factory.build([[nil,'b'],[:add,'c'],[:sbt,'a',:lft],
        [:div,'d',:lft]])
      expected_exp = expression_factory.build([[nil,'d'],[:div,[[nil,'a'],[:sbt,[[nil,'b'],
        [:add,'c']]]]]])
      expect(exp.convert_lft_steps).to eq expected_exp
    end
  end

  describe 'simplify_a_m_form' do
    it 'sorts a consecutive collection of mtp ele steps' do
      exp = expression_factory.build([[nil,'b'],[:mtp,'a']])
      expected_exp = expression_factory.build([[nil,'a'],[:mtp,'b']])
      expect(exp.simplify_a_m_form).to eq expected_exp
    end

    it 'simplify_m_form is a mutator method' do
      exp = expression_factory.build([[nil,'b'],[:mtp,'a']])
      expected_exp = expression_factory.build([[nil,'a'],[:mtp,'b']])
      result = exp.simplify_a_m_form
      expect(result.object_id).to eq exp.object_id
      expect(exp).to eq expected_exp
    end

    it 'simplifies an m-form of 3 steps containing two numerical steps' do
      exp = expression_factory.build([[nil,'a'],[:mtp,3],[:mtp,4]])
      expected_exp = expression_factory.build([[nil,12],[:mtp,'a']])
      expect(exp.simplify_a_m_form).to eq expected_exp
    end

    it 'simplifies an m-form of 5 steps containing three numerical steps' do
      exp = expression_factory.build([[nil,2],[:mtp,'b'],[:mtp,4],
        [:mtp,'a'],[:mtp,3]])
      expected_exp = expression_factory.build([[nil,24],[:mtp,'a'],[:mtp,'b']])
      expect(exp.simplify_a_m_form).to eq expected_exp
    end
  end

  describe '#simplify_all_m_forms' do
    it 'simplifies itself if it is an m-form' do
      exp = expression_factory.build([[nil,2],[:mtp,'b'],[:mtp,4],
        [:mtp,'a'],[:mtp,3]])
      expected_exp = expression_factory.build([[nil,24],[:mtp,'a'],[:mtp,'b']])
      expect(exp.simplify_all_m_forms).to eq expected_exp
    end


    it 'finds an m-form in an expression and simplifies it' do
      exp = expression_factory.build([[nil,6],[:add,[[nil,'a'],[:mtp,3],[:mtp,4]]],[:div,11]])
      expected_exp = expression_factory.build([[nil,6],[:add,[[nil,12],[:mtp,'a']]],[:div,11]])
      expect(exp.simplify_all_m_forms).to eq expected_exp
    end

    it 'simplify_all_m_forms is a mutator method' do
      exp = expression_factory.build([[nil,6],[:add,[[nil,'a'],[:mtp,3],[:mtp,4]]]])
      expected_exp = expression_factory.build([[nil,6],[:add,[[nil,12],[:mtp,'a']]]])
      result = exp.simplify_all_m_forms
      expect(result.object_id).to eq exp.object_id
      expect(exp).to eq expected_exp
    end

    it 'finds 2 deeply buried m-forms and simplifies it' do
      exp = expression_factory.build([[nil,6],[:add,[[nil,'a'],[:mtp,3],
        [:mtp,4]]],[:sbt,[[nil,5],[:div,[[nil,7],[:add,[[nil,'e'],[:mtp,2],
        [:mtp,'d']]]]]]]])
      expected_exp = expression_factory.build([[nil,6],[:add,[[nil,12],
        [:mtp,'a']]],[:sbt,[[nil,5],[:div,[[nil,7],[:add,[[nil,2],[:mtp,'d'],
        [:mtp,'e']]]]]]]])
      expect(exp.simplify_all_m_forms).to eq expected_exp
    end
  end

  describe '#similar?' do
    it 'returns true when comparing two m-forms with same string valued steps' do
      expression_1 = expression_factory.build([[nil,2],[:mtp,'x'],[:mtp,'y']])
      expression_2 = expression_factory.build([[nil,3],[:mtp,'x'],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be true
    end

    it 'returns false when comparing two m-forms with diff num of steps' do
      expression_1 = expression_factory.build([[nil,2],[:mtp,'x']])
      expression_2 = expression_factory.build([[nil,3],[:mtp,'x'],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be false
    end

    it 'returns false if there is on non-m-form' do
      expression_1 = expression_factory.build([[nil,2],[:div,'x']])
      expression_2 = expression_factory.build([[nil,3],[:div,'x']])
      expect(expression_1.similar?(expression_2)).to be false
    end

    it 'returns false for two m-form with different string valued steps' do
      expression_1 = expression_factory.build([[nil,2],[:mtp,'x']])
      expression_2 = expression_factory.build([[nil,3],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be false
    end

    it 'returns true for two m-forms where first has no num step' do
      expression_1 = expression_factory.build([[nil,'x'],[:mtp,'y']])
      expression_2 = expression_factory.build([[nil,3],[:mtp,'x'],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be true
    end

    it 'returns true for two m-forms where second has no num step' do
      expression_1 = expression_factory.build([[nil,3],[:mtp,'x'],[:mtp,'y']])
      expression_2 = expression_factory.build([[nil,'x'],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be true
    end

    it 'returns true for two m-forms where both has no num step' do
      expression_1 = expression_factory.build([[nil,'x'],[:mtp,'y']])
      expression_2 = expression_factory.build([[nil,'x'],[:mtp,'y']])
      expect(expression_1.similar?(expression_2)).to be true
    end

    it 'returns true for two m-forms where both has just one num step' do
      expression_1 = expression_factory.build([[nil,2]])
      expression_2 = expression_factory.build([[nil,3]])
      expect(expression_1.similar?(expression_2)).to be true
    end
  end

  describe '#simplify_a_m_sum' do
    it 'combines 2 like terms together' do
      exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,4],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,[[nil,7],[:mtp,'x']]]])
      expect(exp.simplify_a_m_sum).to eq expected_exp
    end

    it 'simplify_a_m_sum is a mutator method' do
      exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,4],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,[[nil,7],[:mtp,'x']]]])
      result = exp.simplify_a_m_sum
      expect(exp).to eq expected_exp
      expect(result.object_id).to eq exp.object_id
    end

    it 'combines 3 like terms together' do
      exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,4],[:mtp,'x']]],[:sbt,[[nil,10],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,[[nil,-3],[:mtp,'x']]]])
      expect(exp.simplify_a_m_sum).to eq expected_exp
    end

    it 'cancels 3 like terms if the coeff is zero' do
      exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,4],[:mtp,'x']]],[:sbt,[[nil,7],[:mtp,'x']]]])
      expected_exp = expression_factory.build([])
      expect(exp.simplify_a_m_sum).to eq expected_exp
    end

    it 'collect 3 like terms amongst other terms' do
      exp = expression_factory.build([[nil,[[nil,'z']]],[:add,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,6],[:mtp,'x']]],[:sbt,[[nil,7],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,[[nil,1],[:mtp,'z']]],
        [:add,[[nil,2],[:mtp,'x']]]])
      result = exp.simplify_a_m_sum
      expect(result).to eq expected_exp
    end

    it 'collect 2 sets of different like terms' do
      exp = expression_factory.build([[nil,'x'],[:add,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,6],[:mtp,'x']]],[:add,[[nil,5],[:mtp,'y']]],[:sbt,[[nil,7],
        [:mtp,'x']]],[:sbt,[[nil,7],[:mtp,'y']]]])
      expected_exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:sbt,[[nil,2],[:mtp,'y']]]])
      result = exp.simplify_a_m_sum
      expect(result).to eq expected_exp
    end

    it 'collect 2 sets same string valued terms' do
      exp = expression_factory.build([[nil,'x'],[:add,'y'],[:sbt,'y'],
        [:add,'x'],[:add,'y'],[:add,'x']])
      expected_exp = expression_factory.build([[nil,[[nil,3],[:mtp,'x']]],
        [:add,[[nil,1],[:mtp,'y']]]])
      result = exp.simplify_a_m_sum
      expect(result).to eq expected_exp
    end

    it 'collect 2 sets same numerical valued terms' do
      exp = expression_factory.build([[nil,'x'],[:add,7],[:sbt,3]])
      expected_exp = expression_factory.build([[nil,[[nil,1],[:mtp,'x']]],
        [:add,[[nil,4]]]])
      result = exp.simplify_a_m_sum
      expect(result).to eq expected_exp
    end

    it 'collect 2 similar terms with no num step' do
      exp = expression_factory.build([[nil,'x'],[:add,[[nil,'a'],[:mtp,'b']]],
        [:add,[[nil,'a'],[:mtp,'b']]]])
      expected_exp = expression_factory.build([[nil,[[nil,1],[:mtp,'x']]],
        [:add,[[nil,2], [:mtp,'a'],[:mtp,'b']]]])
      result = exp.simplify_a_m_sum
      expect(result).to eq expected_exp
    end
  end

  describe '#simplify_all_m_sums' do
    it 'simplfies a given m_sum' do
      exp = expression_factory.build([[nil,'x'],[:add,[[nil,'c'],[:mtp,'d']]],
        [:add,[[nil,4],[:mtp,'c'],[:mtp,'d']]]])
      expected_exp = expression_factory.build([[nil,[[nil,1],[:mtp,'x']]],
        [:add,[[nil,5], [:mtp,'c'],[:mtp,'d']]]])
      result = exp.simplify_all_m_sums
      expect(result).to eq expected_exp
    end

    it 'simplfies a m_sum as value of a step' do
      exp = expression_factory.build([[nil,5],[:div,[[nil,'x'],[:add,[[nil,'a'],
        [:mtp,'b']]],[:add,[[nil,'a'],[:mtp,'b']]]]]])
      expected_exp = expression_factory.build([[nil,5],[:div,[[nil,[[nil,1],
        [:mtp,'x']]],[:add,[[nil,2], [:mtp,'a'],[:mtp,'b']]]]]])
      result = exp.simplify_all_m_sums
      expect(result).to eq expected_exp
    end

    it 'simplifies a m_sum buried 2 layers recursively' do
      exp = expression_factory.build([[nil,'p'],[:sbt,[[nil,'x'],[:add,
        [[nil,'c'],[:mtp,'d']]],[:add,[[nil,4],[:mtp,'c'],[:mtp,'d']]]]],
        [:mtp,[[nil,5],[:div,[[nil,'x'],[:add,[[nil,'a'],[:mtp,'b']]],
        [:add,[[nil,'a'],[:mtp,'b']]]]]]]])
      expected_exp = expression_factory.build([[nil,'p'],[:sbt,[[nil,[[nil,1],
        [:mtp,'x']]],[:add,[[nil,5], [:mtp,'c'],[:mtp,'d']]]]],[:mtp,[[nil,5],
        [:div,[[nil,[[nil,1],[:mtp,'x']]],[:add,[[nil,2], [:mtp,'a'],[:mtp,'b']
        ]]]]]]])
      result = exp.simplify_all_m_sums
      expect(result).to eq expected_exp
    end
  end

  describe '#expand_n_simplify' do
    it 'expands and simplify eg 1' do
      exp = expression_factory.build([[nil,[[nil,'x'],[:add,3]]],[:mtp,[[nil,4],
        [:sbt,'x']]]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,12],[:sbt,
        [[nil,'x'],[:mtp,'x']]]])
      result = exp.expand_n_simplify
      expect(result).to eq expected_exp
    end
  end

  describe '#standardise_linear_exp' do
    it 'standardises e - e by moving the x term to first term' do
      exp = expression_factory.build([[nil,3],[:sbt,'x']])
      expected_exp = expression_factory.build([[nil,'x'],[:sbt,3,:lft]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'is a mutator method that returns self' do
      exp = expression_factory.build([[nil,3],[:sbt,'x']])
      expected_exp = expression_factory.build([[nil,'x'],[:sbt,3,:lft]])
      result = exp.standardise_linear_exp
      expect(result.object_id).to eq exp.object_id
      expect(exp).to eq expected_exp
    end

    it 'standardises 2x - 3 by moving the x term to first term' do
      exp = expression_factory.build([[nil,[[nil,2],[:mtp,'x']]],[:sbt,3]])
      expected_exp = expression_factory.build([[nil,'x'],[:mtp,2,:lft],[:sbt,3]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'standardises 3 - 2x' do
      exp = expression_factory.build([[nil,3],[:sbt,[[nil,2],[:mtp,'x']]]])
      expected_exp = expression_factory.build([[nil,'x'],[:mtp,2,:lft],
        [:sbt,3,:lft]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'standardises (4 + (3 - x) ) div 2 - 5' do
      exp = expression_factory.build([[nil,4],[:add,[[nil,3],[:sbt,'x']]],
        [:div,2],[:sbt,5]])
      expected_exp = expression_factory.build([[nil,'x'],[:sbt,3,:lft],
        [:add,4,:lft],[:div,2],[:sbt,5]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'standardises 4 + (3 - x) [(x),(:sbt,3,:lft)] ' do
      exp = expression_factory.build([[nil,4],[:add,[[nil,'x'],[:sbt,3,:lft]]]])
      expected_exp = expression_factory.build([[nil,'x'],[:sbt,3,:lft],
        [:add,4,:lft]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'change any right numerical mtp to left recurisively as standard' do
      exp = expression_factory.build([[nil,4],[:add,[[nil,'x'],[:mtp,3]]],
        [:mtp,11]])
      expected_exp = expression_factory.build([[nil,'x'],[:mtp,3,:lft],
        [:add,4,:lft],[:mtp,11,:lft]])
      expect(exp.standardise_linear_exp).to eq expected_exp
    end

    it 'standardises a monster example' do
      crazy_x_exp = expression_factory.build([[nil,3],[:sbt,[[nil,4],[:div,
        [[nil,[[nil,6],[:mtp,[[nil,7],[:div,[ [nil,'x'],[:add,8,:lft]]]]]]],
        [:sbt,5,:lft]]]]]])
      exp = expression_factory.build([[nil,11],[:mtp,crazy_x_exp],[:add,9],
        [:div,10]])
      expected_exp = expression_factory.build([[nil,'x'],[:add,8,:lft],
        [:div,7,:lft],[:mtp,6,:lft],[:sbt,5,:lft],[:div,4,:lft],[:sbt,3,:lft],
        [:mtp,11,:lft],[:add,9],[:div,10]])
      result = exp.standardise_linear_exp
      expect(result).to eq expected_exp
    end

    it 'is a mutator method which returns the object itself' do
      exp = expression_factory.build([[nil,5],[:add,'x']])
      expected_exp = expression_factory.build([[nil,5],[:add,'x']])
      expect(exp.expand.object_id).to eq exp.object_id
    end
  end

  describe '#expand_with_details' do
    # it 'expands (a+3)4' do
      # exp = expression_factory.build([[nil,'x'],[:add,3],[:mtp,4]])
      # result = exp.expand_with_details
      # stage_1 = expression_factory.build([[nil,'x'],[:add,3],[:mtp,4]])
      # stage_2 = msum_factory.build([[nil,[4,'x']],[:add,[12]]])
      # expected_result = [stage_1,stage_2]
      # expect(result).to eq expected_result
    # end
    context '#_expand_wd_part_1' do
      it 'wrap each ele steps to msum' do
        exp = expression_factory.build([[nil,3],[:add,'x'],[:mtp,4]])
        ms_1 = msum_factory.build([[nil,[3]]])
        ms_2 = msum_factory.build([[nil,['x']]])
        ms_3 = msum_factory.build([[nil,[4]]])
        expected_exp = expression_factory.build([[nil,ms_1],[:add,ms_2],
          [:mtp,ms_3]])
        exp._expand_wd_part_1
        expect(exp).to eq expected_exp
      end

      it 'returns an array of array with step values for ele steps' do
        exp = expression_factory.build([[nil,3],[:add,'x'],[:mtp,4]])
        ms_1 = msum_factory.build([[nil,[3]]])
        ms_2 = msum_factory.build([[nil,['x']]])
        ms_3 = msum_factory.build([[nil,[4]]])
        expected_array = [[ms_1],[ms_2],[ms_3]]
        array = exp._expand_wd_part_1
        expect(array).to eq expected_array
      end
    end

    context '#_expand_wd_part_2' do
      it 'builds the initial expansion_details array' do
        ms_1_1 = msum_factory.build([[nil,[3]]])
        ms_2_1 = msum_factory.build([[nil,['x']]])
        ms_3_1 = msum_factory.build([[nil,[4]]])
        ms_2_2 = msum_factory.build([[nil,['y']]])
        ms_3_2 = msum_factory.build([[nil,[12]]])
        ms_2_3 = msum_factory.build([[nil,[11]]])
        step_stage_arrays = [[ms_1_1],[ms_2_1,ms_2_2,ms_2_3],[ms_3_1,ms_3_2]]
        exp = expression_factory.build([[nil,ms_1_1],[:add,ms_2_1],[:mtp,ms_3_1]])
        exp_1 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_1],[:mtp,ms_3_1]])
        exp_2 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_2],[:mtp,ms_3_2]])
        exp_3 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_3],[:mtp,ms_3_2]])
        expected_expansion_details = [exp_1,exp_2,exp_3]
        result = exp._expand_wd_part_2(step_stage_arrays)
        expect(result).to eq expected_expansion_details
      end

      it 'does not change self' do
        ms_1_1 = msum_factory.build([[nil,[3]]])
        ms_2_1 = msum_factory.build([[nil,['x']]])
        ms_3_1 = msum_factory.build([[nil,[4]]])
        ms_2_2 = msum_factory.build([[nil,['y']]])
        ms_3_2 = msum_factory.build([[nil,[12]]])
        ms_2_3 = msum_factory.build([[nil,[11]]])
        step_stage_arrays = [[ms_1_1],[ms_2_1,ms_2_2,ms_2_3],[ms_3_1,ms_3_2]]
        exp = expression_factory.build([[nil,ms_1_1],[:add,ms_2_1],[:mtp,ms_3_1]])
        exp_1 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_1],[:mtp,ms_3_1]])
        exp_2 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_2],[:mtp,ms_3_2]])
        exp_3 = expression_factory.build([[nil,ms_1_1],[:add,ms_2_3],[:mtp,ms_3_2]])
        expected_expansion_details = [exp_1,exp_2,exp_3]
        result = exp._expand_wd_part_2(step_stage_arrays)
        expect(exp).to eq exp_1
      end
    end

    context '#_expand_wd_part_1 & part_2' do
      it 'returns an array of expansion_details' do
        exp = expression_factory.build([[nil,3],[:add,'x'],[:mtp,4]])
        step_stage_arrays = exp._expand_wd_part_1
        expansion_details = exp._expand_wd_part_2(step_stage_arrays)
        ms_1 = msum_factory.build([[nil,[3]]])
        ms_2 = msum_factory.build([[nil,['x']]])
        ms_3 = msum_factory.build([[nil,[4]]])
        expected_exp = expression_factory.build([[nil,ms_1],[:add,ms_2],
          [:mtp,ms_3]])
        expect(expansion_details.first).to eq expected_exp
        expect(exp).to eq expected_exp
      end
    end

    context '#_expand_wd_mtp_step' do
      it 'expands a mtp step into the current result arrays' do
        expanded_ms = msum_factory.build([[nil,[9,'a']],[:add,[7,'b']]])
        curr_step_val = msum_factory.build([[nil,[4,'a']],[:sbt,[2,'b']]])
        m_form = mform_factory.build([5,'x'])
        remaining_exp = expression_factory.build([[:sbt,m_form]])
        expanded_steps = expanded_ms.steps
        curr_step = step_factory.build([:mtp,curr_step_val])
        remaining_steps = remaining_exp.steps
        expansion_details = ['stage_1','stage_2']
        exp = expression_factory.build([])
        exp._expand_wd_mtp_step(expanded_steps,curr_step,remaining_steps,expansion_details)
        expected_exp_1 = msum_factory.build([[nil,[36,'a','a']],
          [:add,[28,'a','b']],[:sbt,[18,'a','b']],[:sbt,[14,'b','b']],
          [:sbt,[5,'x']]])
        expected_exp_2 = msum_factory.build([[nil,[36,'a','a']],
          [:add,[10,'a','b']],[:sbt,[14,'b','b']],[:sbt,[5,'x']]])
        expected_expansion_details = ['stage_1','stage_2',expected_exp_1,expected_exp_2]
        expect(expansion_details).to eq expected_expansion_details
      end
    end

    context '#_expand_wd_add_sbt_streak' do
      it 'expands a + - streak into expanded_steps and expansion_details' do
        expanded_ms = msum_factory.build([[nil,[9,'x']],[:add,[8,'y']]])
        expanded_steps = expanded_ms.steps
        ms_3 = msum_factory.build([[nil,[7]]])
        ms_4 = msum_factory.build([[nil,[4]],[:add,['a']]])
        ms_5 = msum_factory.build([[nil,[5]],[:sbt,['b']]])
        step_3 = step_factory.build([:add,ms_3])
        step_4 = step_factory.build([:sbt,ms_4])
        step_5 = step_factory.build([:mtp,ms_5])
        add_sbt_step_streak = [step_3,step_4]
        remaining_steps = [step_5]
        expansion_details = ['stage_1','stage_2']
        exp = expression_factory.build([])
        exp._expand_wd_add_sbt_streak(expanded_steps,add_sbt_step_streak,remaining_steps,expansion_details)

        expected_m_sum_1 = msum_factory.build([[nil,[9,'x']],[:add,[8,'y']],[:add,[7]],[:sbt,[4]],[:sbt,['a']]])
        expected_m_sum_2 = msum_factory.build([[nil,[9,'x']],[:add,[8,'y']],[:add,[3]],[:sbt,[1,'a']]])
        last_step = step_factory.build([:mtp,msum_factory.build([[nil,[5]],[:sbt,['b']]])])

        stage_3 = expression_class.new(expected_m_sum_1.steps + [last_step])
        stage_4 = expression_class.new(expected_m_sum_2.steps + [last_step])
        expected_expansion_details = ['stage_1','stage_2',stage_3,stage_4]
        expect(expansion_details).to eq expected_expansion_details
        expect(expanded_steps).to eq expected_m_sum_2.steps
      end
    end

    # context '#_expand_wd_part_3' do
    #   it 'example 1' do
    #     ms_1 = msum_factory.build([[nil,['x']]])
    #     ms_2 = msum_factory.build([[nil,[3]],[:add,['x']]])
    #     ms_3 = msum_factory.build([[nil,[4]],[:add,['y']]])
    #     ms_4 = msum_factory.build([[nil,[5]],[:add,['z']]])
    #     exp = expression_factory.build([[nil,ms_1],[:add,ms_2],[:sbt,ms_3],
    #       [:mtp,ms_4]])
    #     stage_1 = expression_factory.build([[nil,ms_1],[:add,ms_2],[:sbt,ms_3],
    #       [:mtp,ms_4]])
    #     # expected_expansion_details = [stage_1]
    #     stage_1._expand_wd_part_3([])
    #   end
    # end


  end

end
