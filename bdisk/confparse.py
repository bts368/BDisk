import _io
import copy
import os
import validators
from urllib.parse import urlparse
import lxml.etree
import lxml.objectify as objectify

etree = lxml.etree

_profile_specifiers = ('id', 'name', 'uuid')

def _detect_cfg(cfg):
    if isinstance(cfg, str):
        # check for path or string
        try:
            etree.fromstring(cfg)
        except lxml.etree.XMLSyntaxError:
            path = os.path.abspath(os.path.expanduser(cfg))
            try:
                with open(path, 'r') as f:
                    cfg = f.read()
            except FileNotFoundError:
                raise ValueError('Could not open {0}'.format(path))
    elif isinstance(cfg, _io.TextIOWrapper):
        _cfg = cfg.read()
        cfg.close()
        cfg = _cfg
    elif isinstance(self.cfg,  _io.BufferedReader):
        _cfg = cfg.read().decode('utf-8')
        cfg.close()
        cfg = _cfg
    elif isinstance(cfg, bytes):
        cfg = cfg.decode('utf-8')
    else:
        raise TypeError('Could not determine the object type.')
    return(cfg)

def _profile_xpath_gen(selector):
    xpath = ''
    for i in selector.items():
        if i[1] and i[0] in _profile_specifiers:
            xpath += '[@{0}="{1}"]'.format(*i)
    return(xpath)

class Conf(object):
    def __init__(self, cfg, profile = None):
        """
        A configuration object.

        Read a configuration file, parse it, and make it available to the rest
        of BDisk.

        Args:

        cfg           The configuration. Can be a filesystem path, a string,
                      bytes, or a stream. If bytes or a bytestream, it must be
                      in UTF-8 format.

        profile       (optional) A sub-profile in the configuration. If None
                        is provided, we'll first look for the first profile
                        named 'default' (case-insensitive). If one isn't found,
                        then the first profile found will be used. Can be a
                        string (in which we'll automatically search for the
                        given value in the "name" attribute) or a dict for more
                        fine-grained profile identification, such as:

                            {'name': 'PROFILE_NAME',
                             'id': 1,
                             'uuid': '00000000-0000-0000-0000-000000000000'}

                        You can provide any combination of these
                        (e.g. "profile={'id': 2, 'name' = 'some_profile'}").
        """
        self.raw = _detect_cfg(cfg)
        self.profile = profile
        self.xml = None
        self.profile = None
        self.xml = etree.from_string(self.cfg)
        self.xsd = None
        #if not self.validate():  # Need to write the XSD
        #    raise ValueError('The configuration did not pass XSD/schema '
        #                     'validation')
        self.get_profile()
        self.max_recurse = int(self.profile.xpath('//meta/'
                                                  'max_recurse')[0].text)

    def get_xsd(self):
        path = os.path.join(os.path.dirname(__file__),
                            'bdisk.xsd')
        with open(path, 'r') as f:
            xsd = f.read()
        return(xsd)

    def validate(self):
        self.xsd = etree.XMLSchema(self.get_xsd())
        return(self.xsd.validate(self.xml))

    def get_profile(self):
        """Get a configuration profile.

        Get a configuration profile from the XML object and set that as a
        profile object. If a profile is specified, attempt to find it. If not,
        follow the default rules as specified in __init__.
        """
        if self.profile:
            # A profile identifier was provided
            if isinstance(self.profile, str):
                _profile_name = self.profile
                self.profile = {}
                for i in _profile_specifiers:
                    self.profile[i] = None
                self.profile['name'] = _profile_name
            elif isinstance(self.profile, dict):
                for k in _profile_specifiers:
                    if k not in self.profile.keys():
                        self.profile[k] = None
            else:
                raise TypeError('profile must be a string (name of profile), '
                                'a dictionary, or None')
            xpath = ('/bdisk/'
                     'profile{0}').format(_profile_xpath_gen(self.profile))
            self.profile = self.xml.xpath(xpath)
            if not self.profile:
                raise RuntimeError('Could not find the profile specified in '
                                   'the given configuration')
        else:
            # We need to find the default.
            profiles = []
            for p in self.xml.xpath('/bdisk/profile'):
                profiles.append(p)
            # Look for one named "default" or "DEFAULT" etc.
            for idx, value in enumerate([e.attrib['name'].lower() \
                                         for e in profiles]):
                if value == 'default':
                    self.profile = copy.deepcopy(profiles[idx])
                    break
            # We couldn't find a profile with a default name. Try to grab the
            # first profile.
            if not self.profile:
                # Grab the first profile.
                if profiles:
                    self.profile = profile[0]
                else:
                    # No profiles found.
                    raise RuntimeError('Could not find any usable '
                                       'configuration profiles')
        return()

    def parse_profile(self):
        pass

    def _xpath_ref(self, element):
        data = None
        # This is incremented each recursive call until we reach
        # self.max_recurse
        recurse_cnt = 1
        return(data)