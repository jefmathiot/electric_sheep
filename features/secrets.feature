Feature: Use encrypted secrets
  In order to share my Sheepfile without disclosing secrets
  As a backup operator
  I want Electric Sheep to decrypt secrets using public-key cryptography

  Scenario: Encrypt a secret in the standard armor format
    Given a secret
    When I tell the sheep to encrypt the secret
    Then I should see the ASCII-armored cipher text

  Scenario: Encrypt a secret in compact format
    Given a secret
    When I tell the sheep to encrypt a secret in compact format
    Then I should only see the data part of the cipher text

  Scenario: Use encrypted credentials
    Given Electric Sheep has access to a valid private key
    When I tell the sheep to work on configuration "Sheepfile.secrets"
    Then everything goes well
