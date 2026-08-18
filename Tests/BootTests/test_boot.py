"""
Boot-integration tests.
Each test reads the captured boot log and checks for specific,
expected behavior. Adding a new module's app? Add a new test
function here -- the pipeline itself never needs to change.
"""

LOG_FILE = "Tests/BootTests/boot_output.log"


def read_log():
    with open(LOG_FILE, "r") as f:
        return f.read()


def test_ovmf_reached_bds_phase():
    log = read_log()
    assert "BdsDxe" in log, "Firmware never reached BDS phase"


def test_fan_control_triggers_alert_above_threshold():
    log = read_log()
    assert "ALERT: threshold exceeded" in log, \
        "FanControlApp did not alert on a temperature above threshold"


# When someone adds a new module (e.g. PowerSequencing), they add a new
# function here too -- for example:
#
# def test_power_sequencing_staggers_boot():
#     log = read_log()
#     assert "Power stage 1 OK" in log