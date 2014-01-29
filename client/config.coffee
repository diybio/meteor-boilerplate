# TODO update configuration
# http://github.differential.io/accounts-entry/

Meteor.startup ->
  Accounts.ui.config
    passwordSignupFields: 'EMAIL_ONLY'

  AccountsEntry.config
    logo: ''
    privacyUrl: '/privacy-policy'
    termsUrl: '/terms-of-use'
    homeRoute: '/'
    dashboardRoute: '/dashboard'
    profileRoute: 'profile'
    showSignupCode: false