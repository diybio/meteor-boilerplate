Template.entrySignUp.helpers
  showEmail: ->
    fields = Accounts.ui._options.passwordSignupFields

    _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_AND_OPTIONAL_EMAIL',
      'EMAIL_ONLY'], fields)

  showUsername: ->
    fields = Accounts.ui._options.passwordSignupFields

    _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_AND_OPTIONAL_EMAIL',
      'USERNAME_ONLY'], fields)

  showSignupCode: ->
    AccountsEntry.settings.showSignupCode

  logo: ->
    AccountsEntry.settings.logo

  privacyUrl: ->
    AccountsEntry.settings.privacyUrl

  termsUrl: ->
    AccountsEntry.settings.termsUrl

  both: ->
    AccountsEntry.settings.privacyUrl &&
    AccountsEntry.settings.termsUrl

  neither: ->
    !AccountsEntry.settings.privacyUrl &&
    !AccountsEntry.settings.termsUrl

Template.entrySignUp.events
  'submit #signUp': (event, t) ->
    event.preventDefault()

    username =
      if t.find('input[name="username"]')
        t.find('input[name="username"]').value
      else
        undefined

    signupCode =
      if t.find('input[name="signupCode"]')
        t.find('input[name="signupCode"]').value
      else
        undefined

    email = t.find('input[type="email"]').value
    password = t.find('input[type="password"]').value

    # XXX collect contents of address fields
    # be sure name attribute of each address field in signUp.html
    # are unique and match those used here
    orgn = t.find('input[name="orgn"]').value
    add1 = t.find('input[name="add1"]').value
    add2 = t.find('input[name="add2"]').value
    lcty = t.find('input[name="lcty"]').value
    admn = t.find('input[name="admn"]').value
    pcde = t.find('input[name="pcde"]').value
    ctry = t.find('input[name="ctry"]').value

    fields = Accounts.ui._options.passwordSignupFields

    trimInput = (val)->
      val.replace /^\s*|\s*$/g, ""

    passwordErrors = do (password)->
      errMsg = []
      msg = false
      # XXX improve password strength
      if password.length < 1
        errMsg.push "1 character minimum password."
      # if password.search(/[a-z]/i) < 0
      #   errMsg.push "Password requires 1 letter."
      # if password.search(/[0-9]/) < 0
      #   errMsg.push "Password must have at least one digit."

      if errMsg.length > 0
        msg = ""
        errMsg.forEach (e) ->
          msg = msg.concat "#{e}\r\n"

        Session.set 'entryError', msg
        return true

      return false

    if passwordErrors then return

    email = trimInput email

    # XXX left-side symbol corresponds to property name in db; this object is
    # passed in whole-sale to the db by accountsCreateUser server method.
    # see entry.coffee 
    address = 
      orgn: orgn
      add1: add1
      add2: add2
      lcty: lcty
      admn: admn
      pcde: pcde
      ctry: ctry      

    emailRequired = _.contains([
      'USERNAME_AND_EMAIL',
      'EMAIL_ONLY'], fields)

    usernameRequired = _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_ONLY'], fields)

    if usernameRequired && email.length is 0
      Session.set('entryError', 'Username is required')
      return

    if emailRequired && email.length is 0
      Session.set('entryError', 'Email is required')
      return

    if AccountsEntry.settings.showSignupCode && signupCode.length is 0
      Session.set('entryError', 'Signup code is required')
      return

    Meteor.call('entryValidateSignupCode', signupCode, (err, valid) ->
      if err
        console.log err
      if valid
        Meteor.call('accountsCreateUser', username, email, password, address, (err, data) ->
          if err
            Session.set('entryError', err.reason)
            return


          #login on client
          if  _.contains([
            'USERNAME_AND_EMAIL',
            'USERNAME_AND_OPTIONAL_EMAIL',
            'EMAIL_ONLY'], Accounts.ui._options.passwordSignupFields)
            Meteor.loginWithPassword(email, password)
          else
            Meteor.loginWithPassword(username, password)

          Router.go AccountsEntry.settings.dashboardRoute
        )
      else
        Session.set('entryError', 'Signup code is incorrect')
        return
    )

