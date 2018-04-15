import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_java_is_installed(host):
    host.run(". /etc/profile")
    host.exists("java")


def test_java_version_131(host):
    java_version = host.check_output(". /etc/profile; java -version 2>&1")
    assert "1.8.0_131" in java_version
