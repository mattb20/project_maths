require './models/expression'

describe Expression do
  let(:step_1){double(:step_1)}
  let(:step_2){double(:step_2)}
  let(:exp){described_class.new([step_1,step_2])}
  let(:exp_copy){exp.copy}

  describe '#new/initialize' do
    it 'initialize with an array of steps which can be read as attribute' do
      expect(exp.value).to eq [step_1,step_2]
    end
  end

  describe '#==' do
    it 'returns true when all steps are orderedly equal(==)' do
      exp_2 = described_class.new([step_1,step_2])
      expect(exp).to eq exp_2
    end

    it 'returns false when steps are equal but not the same order' do
      exp_2 = described_class.new([step_2,step_1])
      expect(exp).not_to eq exp_2
    end

    it 'returns false when steps are different' do
      step_3 = double(:step_3)
      exp_2 = described_class.new([step_3])
      expect(exp).not_to eq exp_2
    end
  end

  describe '#copy' do
    context 'makes a deep copy by making a copy of each step' do
      before(:each) do
        allow(step_1).to receive(:copy).and_return('copy_of_step_1')
        allow(step_2).to receive(:copy).and_return('copy_of_step_2')
      end

      it 'the copy and original are different objects' do
        expect(exp_copy.object_id).not_to eq exp.object_id
      end

      it 'steps in the copied expression are copies' do
        expect(exp_copy.value).to eq ['copy_of_step_1','copy_of_step_2']
      end
    end
  end

  describe '#responds to forwarded methods from Enumerable' do
    it 'responds to #size' do
      expect(exp).to respond_to(:size)
    end

    it 'responds to #each' do
      expect(exp).to respond_to(:each)
    end

    it 'responds to #[]' do
      expect(exp).to respond_to(:[])
    end

    it 'gives number of steps as size' do
      expect(exp.size).to eq 2
    end
  end

  describe '#expand_to_ms' do
    it 'returns an equivalent m-form-sum expression' do
      ms_klass = double(:ms_klass)
      expect(exp).to receive(:ms_klass).and_return(ms_klass)
      allow(ms_klass).to receive(:new).and_return('ms_exp')
      allow(step_1).to receive(:expand_into_ms).with('ms_exp')
      allow(step_2).to receive(:expand_into_ms).with('ms_exp')
      expect(exp.expand_to_ms).to eq 'ms_exp'
    end
  end

  describe '#ms_klass' do
    it 'returns class name of m-form-sum expression' do
      expect(exp.ms_klass).to eq MtpFormSumExp
    end
  end
end

describe Step do
  describe '#initialize/new' do
    let(:exp){double(:exp)}
    let(:step){described_class.new(:some_ops,exp)}

    it 'with an operation that can be read as an attribute' do
      expect(step.ops).to eq :some_ops
    end

    it 'with a value that can be read as an attribute' do
      expect(step.val).to eq exp
    end

    it 'with a direction (with default) that can be read as an attribute' do
      expect(step.dir).to eq :rgt
    end
  end

  describe '#expand_into_ms' do
    let(:exp){double(:exp)}
    let(:step){described_class.new(:some_ops,exp)}
    let(:ms_exp){double(:ms_exp)}
    let(:klass){double(:klass)}

    it 'relays the message to expand into ms to the val object' do
      allow(exp).to receive(:expand_into_ms).with(ms_exp,step)
        .and_return('expanded_ms_exp')
      expect(step.expand_into_ms(ms_exp)).to eq 'expanded_ms_exp'
    end
  end

  describe '#append' do
    let(:exp_1){double(:exp_1)}
    let(:step_1){described_class.new(:ops_1,exp_1)}
    let(:exp_2){double(:exp_2)}
    let(:step_2){described_class.new(:ops_2,exp_2)}

    it 'appends a step into the val of the current step' do
      m_form = double(:m_form)
      allow(exp_1).to receive(:convert_to_m_form).and_return(m_form)
      value_array = []
      allow(m_form).to receive(:value).and_return(value_array)
      step_1.append(step_2)
      expect(m_form.value).to eq [step_2]
      expect(step_1.val).to eq m_form
    end
  end
end

describe NumExp do
  let(:number){double(:number)}
  let(:num_exp){described_class.new(number)}

  describe '#initializes/new' do
    it 'initializes with a numerical value that can be read as an attribute' do
      expect(num_exp.value).to eq number
    end
  end

  describe '#expand_into_ms' do
    it 'expands an nil step into an m-form-sum exp' do
      ms_exp = double(:ms_exp)
      step = double(:step)
      allow(step).to receive(:ops).and_return(nil)
      value_steps = []
      allow(ms_exp).to receive(:value).and_return(value_steps)
      num_exp.expand_into_ms(ms_exp,step)
      expect(ms_exp.value).to eq [step]
    end

    it 'expands an add step into an m-form-sum exp' do
      ms_exp = double(:ms_exp)
      step = double(:step)
      allow(step).to receive(:ops).and_return(:add)
      value_steps = []
      allow(ms_exp).to receive(:value).and_return(value_steps)
      num_exp.expand_into_ms(ms_exp,step)
      expect(ms_exp.value).to eq [step]
    end

    it 'expands an sbt step into an m-form-sum exp' do
      ms_exp = double(:ms_exp)
      step = double(:step)
      allow(step).to receive(:ops).and_return(:sbt)
      value_steps = []
      allow(ms_exp).to receive(:value).and_return(value_steps)
      num_exp.expand_into_ms(ms_exp,step)
      expect(ms_exp.value).to eq [step]
    end

    it 'expands an mtp step into an m-form-sum exp' do
      ms_exp = double(:ms_exp)
      step = double(:step)
      allow(step).to receive(:ops).and_return(:mtp)
      mf_step = double(:mf_step)
      value_steps = [mf_step]
      allow(ms_exp).to receive(:value).and_return(value_steps)
      allow(mf_step).to receive(:append)
      num_exp.expand_into_ms(ms_exp,step)
      expect(ms_exp.value).to eq [mf_step]
    end
  end
end
