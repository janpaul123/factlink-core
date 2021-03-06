module PavlovSupport
  # TODO why is this in pavlov support, this should be put in some general
  # support file or spec_helper.
  def stub_classes *classnames
    classnames.each do |classname|
      stub_const classname, Class.new
    end
  end

  def expect_validating hash
    hash[:pavlov_options] ||= {}
    hash[:pavlov_options][:ability] ||= double(can?: true)
    instance = described_class.new(hash)
    instance.valid?
    error_messages = instance.errors.map do |attribute, message|
      "#{attribute} #{message}"
    end
    expect(error_messages)
  end

  def fail_validation message
    include message
  end

  def as user, &block
    ExecuteAsUser.new(user).execute &block
  end
end
