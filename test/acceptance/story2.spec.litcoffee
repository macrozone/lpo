# Story 2

load setup code

	{loadDriver:loadDriver, webdriver: webdriver, helpers: helpers} = require "./setup"
	Constants = require "./constants"

the tests


	describe "story2", ->
		driver = false
		beforeEach -> runs -> waitsFor -> driver = loadDriver()

		it "allows user to open a page for a problem", (done) ->
			element = driver.findElement(webdriver.By.className('problemList'))
			element.findElement(webdriver.By.tagName("a")).click().then ->
				helpers.getTitleOfProblemPage(driver).then (title) ->
					expect(title).toBe Constants.PROBLEM_TITLE
					done()

		it "allows a user to add a solution for a problem", (done) ->
			helpers.createSolution(driver, Constants.SOLUTION_TITLE, Constants.SOLUTION_DESCRIPTION).then done

		it "has an empty form when a solution is saved", (done) ->
			solutionContainer = helpers.getSolutionCreateContainer driver
			
			solutionContainer.findElement(webdriver.By.className('title')).getAttribute("value").then (title) ->
				expect(title).toBe ""
				solutionContainer.findElement(webdriver.By.className('description')).getAttribute("value").then (description) ->
					expect(description).toBe ""
					done()

