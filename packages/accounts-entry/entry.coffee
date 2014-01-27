Meteor.startup ->
  AccountsEntry =
    settings: {}

    config: (appConfig) ->
      @settings = _.extend(@settings, appConfig)

  @AccountsEntry = AccountsEntry

  Meteor.methods
    entryValidateSignupCode: (signupCode) ->
      not AccountsEntry.settings.showSignupCode or signupCode is AccountsEntry.settings.signupCode

    accountsCreateUser: (username, email, password, address) ->
      if username
        Accounts.createUser
          username: username
          email: email
          password: password
          #profile: AccountsEntry.settings.defaultProfile || {}
          #TODO add default profile 
          profile: {address: address}
      else
        Accounts.createUser
          email: email
          password: password
          profile: {address: address}
