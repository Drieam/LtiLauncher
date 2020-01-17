# frozen_string_literal: true

require 'administrate/field/base'

class LaunchesField < Administrate::Field::Base
  def student_context
    Keypair.jwt_encode(
      'https://purl.imsglobal.org/spec/lti/claim/roles': [
        'http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student'
      ]
    )
  end

  def teacher_context
    Keypair.jwt_encode(
      'https://purl.imsglobal.org/spec/lti/claim/roles': [
        'http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty'
      ]
    )
  end
end
