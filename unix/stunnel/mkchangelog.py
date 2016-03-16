#!/usr/bin/env python
""" Simple cross-renderer of changelogs for RPM and Deb packaging """

import yaml
from dateutil import parser
# from pprint import pprint

FILENAME = "changelog.yaml"

def get_changes(filename):
    """ Returns changes as dict """
    fhd = open(filename, 'r')
    changes = yaml.load(fhd)
    fhd.close()
    return changes

def render_rpm_changelog(changes):
    """ Render changelog in RPM changelog format.
    Example on format from https://docs.fedoraproject.org/ro/Fedora_Draft_
    Documentation/0.1/html/RPM_Guide/ch09s06.html
    * Fri Jun 21 2002 Bob Marley <marley@reggae.com>
    - Downloaded version 1.4, applied patches
    * Tue May 08 2001 Peter Tosh <tosh@reggae.com> 1.3-1
    - updated to 1.3
    """
    changes.reverse()
    for item in changes:
        timestamp = parser.parse(item['date'])
        # pylint: disable=maybe-no-member
        item['rpmdate'] = timestamp.strftime("%a %b %d %Y")
        # pylint: enable=maybe-no-member
        print "* %(rpmdate)s %(author)s %(version)s" % item
        print "%(notes)s" % item

if __name__ == '__main__':
    CHANGES = get_changes(FILENAME)
    render_rpm_changelog(CHANGES)
