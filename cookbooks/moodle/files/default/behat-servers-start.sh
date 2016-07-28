#!/usr/bin/env bash

if curl http://localhost:4444/wd/hub/status > /dev/null 2> /dev/null ; then
    echo "Selenium 2.53.1 server is already running"
else
    xvfb-run -a --server-args="-screen 0 1024x768x24" java -jar /usr/local/bin/selenium-server-standalone-2.53.1.jar -Dwebdriver.chrome.driver=/usr/lib/chromium-browser/chromedriver > /dev/null 2> /dev/null &
    echo "Selenium 2.53.1 server started"
fi
