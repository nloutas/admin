import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_eclipse_config(host):
    cfg_line = host.check_output("grep -r Xmx /opt/eclipse-oxygen-4.7/eclipse/eclipse.ini")
    assert "-Xmx2048m" in cfg_line



def test_hosts_file(host):
    f = host.file('//usr/share/applications/eclipse-oxygen-4.7.desktop')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'