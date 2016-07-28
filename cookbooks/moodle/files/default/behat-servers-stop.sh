#!/usr/bin/env bash

if curl http://localhost:4444/wd/hub/status > /dev/null 2> /dev/null ; then
    curl http://localhost:4444/selenium-server/driver/?cmd=shutDownSeleniumServer > /dev/null 2> /dev/null
    echo "Selenium 2.53.1 server has been shutdown"
else
    echo "Selenium 2.53.1 server is not already running"
fi
