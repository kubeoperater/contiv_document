# Contributing

Below are the instructions for making contributions to the Contiv website.

## Prerequisites

Fork this repo to your personal account.

Install [Docker](https://www.docker.com/).

## Running the Site Locally and Testing Your Changes

Running the site locally is simple: run `cd websrc; make dev` then open up `http://localhost:4567`

When you edit the Markdown source files, your changes will be available immediately.  Reload the page to see them.

## Updating Client Library

Go client library documentation is generated via GoDoc.  This is hosted on an external site and is automatically pulled in from Github.  You can trigger a manual refresh by going to the bottom of the [contivmodel client page](https://godoc.org/github.com/contiv/contivmodel/client) and clicking "Refresh Now".

## Submitting Changes

Make changes to the Markdown files and test them using the the above instructions.

When you are ready to submit the changes, run `cd websrc; make build`. This generates the static website content which will be hosted by Github Pages. You can now commit all of the changes together (Markdown files and static content) and submit a pull request.

Please sign your commits (`git commit -s`) and ensure that your PR includes both the source and static content changes!
