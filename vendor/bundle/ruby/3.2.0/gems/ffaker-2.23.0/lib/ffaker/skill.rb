# frozen_string_literal: true

module FFaker
  module Skill
    extend ModuleUtils
    extend self

    def tech_skill
      fetch_sample(TECH_SKILLS)
    end

    def tech_skills(num = 3)
      fetch_sample(TECH_SKILLS, count: num)
    end

    def specialty
      "#{fetch_sample(SPECIALTY_START)} #{fetch_sample(SPECIALTY_END)}"
    end

    def specialties(num = 3)
      (1..num).map { specialty }
    end
  end
end
