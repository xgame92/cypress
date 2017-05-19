YAML = require('yamljs')
_ = require('lodash')

describe "Documentation", ->
  beforeEach ->
    cy.server()
    @mainGuides = "/guides/getting-started/why-cypress"
    @mainAPI = "/api/welcome/api"
    @mainEco = "/ecosystem/index"
    @mainFAQ = "/faq/index"

  context "Pages", ->
    describe "404", ->
      it "displays", ->
        cy
          .visit("/404.html")
          .contains("404")

    describe "Homepage", ->
      beforeEach ->
        cy.visit("/")

      it "displays", ->
        cy.contains("Homepage")

    describe "Navigation", ->
      beforeEach ->
        cy.visit("/")

      it "displays links to pages", ->
        cy.contains(".main-nav-link", "Guides")
          .should("have.attr", "href").and("include", @mainGuides)

        cy.contains(".main-nav-link", "API")
          .should("have.attr", "href").and("include", @mainAPI)

        cy.contains(".main-nav-link", "Ecosystem")
          .should("have.attr", "href").and("include", @mainEco)

        cy.contains(".main-nav-link", "FAQ")
          .should("have.attr", "href").and("include", @mainFAQ)

      it "displays link to github repo", ->
        cy
        .get(".main-nav-link").find(".fa-github").parent()
        .should("have.attr", "href")
        .and("eq", "https://github.com/cypress-io/cypress")

        it "displays language dropdown", ->
          cy.contains("select", "English").find("option").contains("English")

      describe "active nav", ->
        it "higlights guides when on a guides page", ->
          cy
            .visit(@mainGuides + ".html")
              .contains(".main-nav-link", "Guides")
                .should("have.class", "active")

        it "higlights api when on a api page", ->
          cy
            .visit(@mainAPI + ".html")
              .contains(".main-nav-link", "API")
                .should("have.class", "active")

        it "higlights eco when on a eco page", ->
          cy
            .visit(@mainEco + ".html")
              .contains(".main-nav-link", "Ecosystem")
                .should("have.class", "active")

        it "higlights FAQ when on a FAQ page", ->
          cy
            .visit(@mainFAQ + ".html")
              .contains(".main-nav-link", "FAQ")
                .should("have.class", "active")

    describe "Search", ->
      beforeEach ->
        cy.visit("/")

      it "posts to Algolia api with correct index on search", ->
        cy
          .route({
            method: "POST",
            url: /algolia/
          }).as("postAlgolia")
          .get("#search-input").type("g")
          .wait("@postAlgolia").then (xhr) ->
            expect(xhr.requestBody.requests[0].indexName).to.eq("cypress")

      it "displays algolia dropdown on search", ->
        cy
          .get(".ds-dropdown-menu").should("not.be.visible")
          .get("#search-input").type("g")
          .get(".ds-dropdown-menu").should("be.visible")

    describe "Guides", ->
      beforeEach ->
        cy.visit(@mainGuides + ".html")

      context "Header", ->
        it.skip "should display capitalized title of doc", ->
          cy
            .contains("h1", "Guides")

        it "should have link to edit doc", ->
          cy
            .contains("a", "Improve this doc").as("editLink")
            .get("@editLink").should("have.attr", "href")
              .and("include", @mainGuides + ".md")
            .get("@editLink").should("have.attr", "href")
              .and("include", "https://github.com/cypress-io/cypress-documentation/edit/master/source/")

      context "Sidebar", ->
        beforeEach ->
          cy.readFile("source/_data/sidebar.yml").then (yamlString) ->
            @sidebar = YAML.parse(yamlString)
            @sidebarTitles = _.keys(@sidebar.guides)

            @sidebarLinkNames =  _.reduce @sidebar.guides, (memo, nestedObj, key) ->
               memo.concat(_.keys(nestedObj))
            , []

            @sidebarLinks =  _.reduce @sidebar.guides, (memo, nestedObj, key) ->
                 memo.concat(_.values(nestedObj))
              , []

          cy.readFile("themes/cypress/languages/en.yml").then (yamlString) ->
              @english = YAML.parse(yamlString)

        it "displays current page as highlighted", ->
          cy
            .get("#sidebar").find(".current")
            .should("have.attr", "href").and("include", "why-cypress.html")

        it "displays English titles in sidebar", ->
          cy
            .get("#sidebar")
              .find(".sidebar-title").each (displayedTitle, i) ->
                englishTitle  = @english.sidebar.guides[@sidebarTitles[i]]

                expect(displayedTitle.text()).to.eq(englishTitle)

        it "displays English link names in sidebar", ->
          cy
            .get("#sidebar")
              .find(".sidebar-link").first(5).each (displayedLink, i) ->
                englishLink  = @english.sidebar.guides[@sidebarLinkNames[i]]

                expect(displayedLink.text().trim()).to.eq(englishLink)

        it "displays English links in sidebar", ->
          cy
            .get("#sidebar")
              .find(".sidebar-link").each (displayedLink, i) ->
                sidebarLink  = @sidebarLinks[i]

                expect(displayedLink.attr('href')).to.include(sidebarLink)

      context.skip "Table of Contents", ->

      context "Pagination", ->
        beforeEach ->
          @firstPage = "why-cypress.html"
          @nextPage = "installing-cypress.html"

        it "does not display Prev link on first page", ->
          cy.get(".article-footer-prev").should("not.exist")

        it "displays Next link", ->
          cy.get(".article-footer-next").should("have.attr", "href").and("include", @nextPage)

        describe "click on Next page", ->
          beforeEach ->
            cy.get(".article-footer-next").click()
            cy.url().should("contain", @nextPage)

          it "should display Prev link", ->
            cy.get(".article-footer-prev").should("be.visible")

          it "clicking on Prev link should go back to original page", ->
            cy.get(".article-footer-prev").click()
            cy.url().should("contain", @firstPage)

      context "Comments", ->
        it "displays comments section", ->
          cy.get("#comments").should("be.visible")