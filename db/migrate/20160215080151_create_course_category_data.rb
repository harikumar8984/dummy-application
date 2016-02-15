class CreateCourseCategoryData < ActiveRecord::Migration
  def up
    CourseCategory.find_or_create_by(name: "Prenatal_5")
    CourseCategory.find_or_create_by(name: "Prenatal_6")
    CourseCategory.find_or_create_by(name: "Prenatal_7")
    CourseCategory.find_or_create_by(name: "Prenatal_8")
    CourseCategory.find_or_create_by(name: "Prenatal_9")
    CourseCategory.find_or_create_by(name: "Month_1")
    CourseCategory.find_or_create_by(name: "Month_2")
    CourseCategory.find_or_create_by(name: "Month_3")
    CourseCategory.find_or_create_by(name: "Month_4")
    CourseCategory.find_or_create_by(name: "Month_5")
    CourseCategory.find_or_create_by(name: "Month_6")
    CourseCategory.find_or_create_by(name: "Month_7")
    CourseCategory.find_or_create_by(name: "Month_8")
    CourseCategory.find_or_create_by(name: "Month_9")
    CourseCategory.find_or_create_by(name: "Month_10")
    CourseCategory.find_or_create_by(name: "Month_11")
    CourseCategory.find_or_create_by(name: "Month_12")
    CourseCategory.find_or_create_by(name: "Month_13")
    CourseCategory.find_or_create_by(name: "Month_14")
    CourseCategory.find_or_create_by(name: "Month_15")
    CourseCategory.find_or_create_by(name: "Month_16")
    CourseCategory.find_or_create_by(name: "Month_17")
    CourseCategory.find_or_create_by(name: "Month_18")
    CourseCategory.find_or_create_by(name: "Month_19")
    CourseCategory.find_or_create_by(name: "Month_20")
    CourseCategory.find_or_create_by(name: "Month_21")
    CourseCategory.find_or_create_by(name: "Month_22")
    CourseCategory.find_or_create_by(name: "Month_23")
    CourseCategory.find_or_create_by(name: "Month_24")

    CourseCategory.all.each do |course_category|
      course = Course.where(criteria: course_category.name).first
      course.update_attributes(course_category_id: course_category.id) unless course.blank?
    end

  end
end



