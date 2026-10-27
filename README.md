Assignment 3: DevOps Diagnostic CLI Tool

Overview

This project is a Bash command-line application that provides basic system information, checks whether a hostname can be resolved, and checks whether a port is valid and accessible.

Features

- Display system information.
- Check whether a hostname resolves.
- Check whether a port is accessible on a host.
- Display usage instructions.
- Validate commands and arguments.
- Run automated tests.
- Build and test a Docker image.
- Run automated validation, testing, and Docker checks through GitHub Actions.

Project Structure

assignment-3/
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── grade.sh
└── README.md

Requirements

- Bash
- Docker
- Git
- Ubuntu or another compatible Linux environment

Usage

Run the application directly:

./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port localhost 80

The "check-port" command checks whether the specified port is accessible. The result depends on whether a service is listening on that port.

Invalid commands or arguments return exit code "2".

Testing

Run the automated tests:

./tests/test.sh

Run the Bash lint checks:

./scripts/lint.sh

Build the Docker image and run smoke tests:

./scripts/build.sh

Run the project grading script:

./grade.sh

Docker

Build the image:

docker build -t devops-tool .

Run the help command:

docker run --rm devops-tool help

Display system information:

docker run --rm devops-tool system-info

Continuous Integration

The GitHub Actions workflow runs when changes are pushed or a pull request is opened. It validates and lints the Bash scripts, runs the application tests, and builds and smoke-tests the Docker image.

An intentional test failure was introduced to demonstrate that the CI pipeline detects failures. The test was then corrected, and the fix was committed and pushed.

Assumptions and Limitations

- The application is designed for Bash-compatible Linux environments.
- Hostname checks depend on network and DNS availability.
- Port checks depend on network access and whether a service is listening.
- The automated tests validate command behavior and argument handling.

Author

Hikmah
