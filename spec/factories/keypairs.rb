# frozen_string_literal: true

FactoryBot.define do
  factory :keypair do
    trait :fixed do
      _keypair do
        <<~RSA
          -----BEGIN RSA PRIVATE KEY-----
          MIIEogIBAAKCAQEAvPRsNZ6YfIkX1fsK9bMv7jxEWwT/JlPh8JsoRrAEYkVLkC7s
          5jwY8+RmdtLsa/jKxX96jJ+vL8B64chmc8DT7baotwCxquiRR1PIkWnp1peOmmsO
          rAuFzad+83SHhU5ajVLY9NsOSlelDI2D3EryPAm3FV4RuJryhKqWjX4uUME3+h3A
          CEgA2kfJQjac22s0kbVgywwiINnKq0pQNGUtH/pRwPOkpaOe7jcLC7b0XuwMf0TZ
          7Lk/7OkNtPFtQxQ3Nu1r7HMVSdTlF4mvVNMIRqd/G978LN52Oef+0epxeIKUCMoh
          ONia1BpH7+43i59+4Ibk4UHhTEQD0RJCo6a8IwIDAQABAoIBAAyBHFwcB7lOFT66
          40nJNuXMJTXkycHOkUgr7GlpIpEiRtLe2ByQY5JYThOU98JZb4nMWt7NfnlpgnhI
          m8cTPrMfgGDD8f3+cAbJW5+L48aotu4vIYRvKsamS/dugb1npwRtNCBYEsUGscx3
          3P8KEqe4eN44IHIYBu6Sn23zqLr9QUekDL6JYMevghE1DnZUXsHUcFUvNyKJn4+J
          aiq1QtZkNlFuYdYADbbmqtnZIUScqGDBaJOBqdSugFLTQriUraBeu7n68B8GVm5n
          I/CxT9fL0GjnLGLO6hDBuPKS5hta0235qYW9mMXALAPvD1tdbB1hsdyv+s6zXU7j
          sa9X3pECgYEA45JRs/QZDJ1tSkO5kl1sgD/loJzEWZm9wq+p2eiNDTm8qts9PojQ
          nKYNivSiDTK+RS7qriCjXdoPDabkHUvOPzvrcWnry0LSUH75tIwNxSq7icqWyGmD
          SkPOHc/onrWimfpuuXgAw10UritAe5hxh/9c1dfuh/vDdAhdbdyi+6kCgYEA1I8m
          CmQ3foi+xJqMaFKAf+RODxAk8ER7eNVCvqf1yHEg3SoGPyHZGwRRTJaUv6PFmLea
          X3Nprna0osXi9TEYn6xc0LxV78b/bNO7lI80Ub3LPsOGGryb/aUCsuPplQEIxvNR
          OShAWSBuvdPYGS/9iLAQqaof2SBxr7PepbsO+OsCgYBKI7Y4gVLT2EntwuinNYaO
          tcJytAAIDN1UmvQkCO5DG8dKhoiKYfpMvpB078QHtrtkQKe2OO3gOpVi5jc1EChO
          U5Ad79sg6lEoZmWlm2c1D/nvJzA+dJmQTUzOS5jGc/hYX81I4T6mZyHAqFimq4B5
          RQmSpXmRlcUUfVEq5JG4mQKBgCqRpJeuLGL99d6f6QC3jR6P1YY0wIER5fx0EVLn
          hlSnO2KvmOKp37YGblW9Tnr2zIriMlttXLvg8BotMV/Tfk/0D/6JyVgk7WCZItcE
          uwCn1v1x4PiXz1HD6z9yX4RE2cImVpzwz7pJwYPo2j1pHAh04lFoTcqJMdtzVWKx
          jLUTAoGAQlrKkScDRqNynKYyW053CfRCQtVCIGw3V0f9jINMLvGFOtIqYSzGCCvQ
          gLXLfrOUKW0nomLVNP5WNZnsr1shtCDQZMql0XozL/KbJCiZ6QNV7gLLYKtKk+PG
          M0FuhHMfRZoBApWu2b7oQrR/dSjDqiOAnG40b5ocvFg8lTJ81i0=
          -----END RSA PRIVATE KEY-----
        RSA
      end
    end
  end
end
