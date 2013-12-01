webdriver = require 'selenium-webdriver'



request = require('request')

driver = false

getWebdriverSessions = ->
    deferred = webdriver.promise.defer()
    request.get {
        url: 'http://localhost:4444/wd/hub/sessions',
        headers: {
            'Content-type': 'application/json'
        }
    }, (error, response, body) ->
        deferred.resolve JSON.parse(body).value
    deferred.promise

getWebdriverSessionStatus = (sessionId, callback) ->
    deferred = webdriver.promise.defer()
    request.get {
        url: 'http://localhost:4444/wd/hub/session/' + sessionId + '/url',
        headers: {
            'Content-type': 'application/json'
        }
    }, (error, response) ->
        deferred.resolve response.statusCode
    deferred.promise

reuseOrCreateSession = (sessions) ->
    deferred = webdriver.promise.defer()

    if sessions.length == 0
        driver = require('../rtd/webdrivers/selenium-server.js') webdriver, browserName: 'chrome'
        driver.manage().timeouts().setScriptTimeout 2000
        driver.manage().timeouts().implicitlyWait 2000
        deferred.resolve driver

    else
        tempDriver = require('../rtd/webdrivers/selenium-server.js') webdriver, browserName: 'chrome', sessions[0].id
        getWebdriverSessionStatus(sessions[0].id).then (status)->
            if status != 200
                deleteWebdriverSessions sessions
                tempDriver = require('../rtd/webdrivers/selenium-server.js') webdriver, browserName: 'chrome'

            tempDriver.manage().timeouts().setScriptTimeout 2000
            tempDriver.manage().timeouts().implicitlyWait 2000
            driver = tempDriver
            deferred.resolve driver
    deferred.promise



initWebDriverSession = ->
    deferred = webdriver.promise.defer()
    getWebdriverSessions().then (sessions) ->
        reuseOrCreateSession(sessions).then deferred.resolve
    deferred.promise



initDriver = ->
    deferred = webdriver.promise.defer()
    initWebDriverSession().then (theDriver) ->
        resetApp().then ->
            openApp().then ->
                driver = theDriver

openApp = ->
    deferred = webdriver.promise.defer()
    driver.get("http://localhost:8000").then deferred.resolve
    deferred.promise

resetApp = ->
    deferred = webdriver.promise.defer()
    driver.get("http://localhost:8000/reset").then deferred.resolve
    deferred.promise


initDriver()

loadDriver = ->

    driver

module.exports = 
    loadDriver: loadDriver
    webdriver: webdriver



