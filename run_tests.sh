#!/bin/bash

# Create/empty the report file
REPORT_FILE="test_report.txt"
echo "Integration Test Report - $(date)" > $REPORT_FILE
echo "=====================================" >> $REPORT_FILE

# Helper function to run a test and log the output
run_test() {
  TEST_NAME="$1"
  TEST_COMMAND="$2"

  echo "Running test: $TEST_NAME" # Print test name to console
  echo "Running test: $TEST_NAME" >> $REPORT_FILE
  echo "-------------------------------------" >> $REPORT_FILE

  # Run the test command, stream output live to console and append to report file
  eval $TEST_COMMAND 2>&1 | tee -a $REPORT_FILE
  STATUS=${PIPESTATUS[0]} # Capture the exit status of the command

  # Check the test result
  if [ $STATUS -eq 0 ]; then
    echo "✅ $TEST_NAME PASSED" | tee -a $REPORT_FILE
  else
    echo "❌ $TEST_NAME FAILED" | tee -a $REPORT_FILE
  fi

  echo "" >> $REPORT_FILE
}

# Add tests here
run_test "Login test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/login_venue_test.dart -d web-server --headless --browser-name=chrome"
run_test "Deals test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/deal_test.dart -d web-server --headless --browser-name=chrome"
run_test "Notification (mocked) test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/notification_mocked_test.dart -d web-server --headless --browser-name=chrome"
run_test "Event test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/event_test.dart -d web-server --headless --browser-name=chrome"
run_test "Navigation test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/navigation_test.dart -d web-server --headless --browser-name=chrome"
run_test "Create Venue test" "flutter drive --driver=test_driver/integration_test.dart --target=test_integration/create_venue_test.dart -d web-server --headless --browser-name=chrome"

# Final summary
echo "Test run completed. See the full report in $REPORT_FILE."
echo "Test run completed. See the full report in $REPORT_FILE." >> $REPORT_FILE
