require "test_helper"

class JobClassTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    job_class = JobClass.new(
      name: "テストジョブ",
      job_type: "basic",
      max_level: 50,
      exp_multiplier: 1.0
    )
    assert job_class.valid?
  end

  test "should require name" do
    job_class = JobClass.new(job_type: "basic", max_level: 50, exp_multiplier: 1.0)
    assert_not job_class.valid?
    assert_includes job_class.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    existing_job = job_classes(:warrior)
    job_class = JobClass.new(
      name: existing_job.name,
      job_type: "basic",
      max_level: 50,
      exp_multiplier: 1.0
    )
    assert_not job_class.valid?
    assert_includes job_class.errors[:name], "has already been taken"
  end

  test "should require valid job_type" do
    job_class = JobClass.new(
      name: "テストジョブ",
      job_type: "invalid",
      max_level: 50,
      exp_multiplier: 1.0
    )
    assert_not job_class.valid?
    assert_includes job_class.errors[:job_type], "is not included in the list"
  end
end
