from readme import parse_readme
from parser import Parser
from nix import format_nix
from create_plugin_file import PluginFile
from data import Table, FunctionBody
import requests
import json
from types import SimpleNamespace
from pprint import pprint
from errors import *
from log import *
#  import subprocess
import sys

def deep_merge(source, destination):
    """
    >>> a = { 'first' : { 'all_rows' : { 'pass' : 'dog', 'number' : '1' } } }
    >>> b = { 'first' : { 'all_rows' : { 'fail' : 'cat', 'number' : '5' } } }
    >>> merge(b, a) == { 'first' : { 'all_rows' : { 'pass' : 'dog', 'fail' : 'cat', 'number' : '5' } } }
    True
    """
    for key, value in source.items():
        if isinstance(value, dict):
            # get node or create one
            node = destination.setdefault(key, {})
            deep_merge(value, node)
        else:
            destination[key] = value

    return destination

def get_plugins_json() -> dict:
    """fetch plugins awailable in NixNeovimPlugins"""

    url = "https://raw.githubusercontent.com/NixNeovim/NixNeovimPlugins/main/.plugins.json"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        data = json.loads(json.dumps(data, indent=2, sort_keys=True))
        return data
    else:
        raise NetworkException(f"Could not fetch plugin data: {response.status_code}")

def main(plugin, repo):

    # convert json to object
    data = json.loads(plugin, object_hook=lambda d: SimpleNamespace(**d))

    name = data.name
    homepage = data.homepage

    # extract relevant lua snippets from README
    lua: list[str]|None = parse_readme(repo)

    if lua is None:
        return

    # parse extracted code block to lua

    code_list = [] # list of extraced code blocks
    for j, section in enumerate(lua):
        debug(f"Parsing {j+1}/{len(lua)}")
        parsed = Parser().parse(section)
        if parsed is not None:
            code_list.append(parsed)

    # clean up final config

    final_config = Table()

    for code in code_list:
        if isinstance(code, Table):
            final_config.merge(code)
        elif isinstance(code, FunctionBody):
            debug("Not adding function body to final_config table")
        else:
            raise Unimplemented(f"Error: unknown code type ({code})")

    final_config.clean()
    pprint(final_config)

    # generate config

    nix_options = format_nix(final_config.to_nix())

    # write new plugin file

    print("skipping writing file")
    #  PluginFile(name, homepage, nix_options)

    info(f"Done")

if __name__ == "__main__":

    try:
        input_name = sys.argv[1]
    except:
        print("nix run .#configparser -- <plugin-name>")
        exit()

    # load plugin information
    plugins = get_plugins_json()

    plugin = None

    if input_name in plugins:
        plugin = plugins[input_name]
        main(plugin, input_name)
    else:
        print(f"Plugin '{input_name}' unknown")
        print()
        print("nix run .#configparser -- <plugin-name>")
        exit()
