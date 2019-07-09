#!/usr/bin/env python

import yaml
import os
import pprint

pp = pprint.PrettyPrinter(indent=4)


def gen_docs(svc):
    with open(os.path.join("./", svc, "values.yaml"), "r") as stream:
        try:
            config = yaml.safe_load(stream)
            try:
                e = config["sidecar"]["envvars"]
            except Exception as err:
                print("No envvars found", svc)
                return

            from pytablewriter import MarkdownTableWriter

            writer = MarkdownTableWriter()
            # writer.table_name = svc + " Sidecar Environment Variable Configuration"
            writer.headers = ["Environment Variable", "Default"]
            table = []
            try:
                for key in e:
                    row = [key, e[key]["value"]]
                    table.append(row)
            except Exception as err:
                print("Improper envvar format", svc)
                return
            writer.value_matrix = table
            return writer.dumps()
        except yaml.YAMLError as exc:
            print(exc)
            return


# from https://stackoverflow.com/a/800201
def get_immediate_subdirectories(a_dir):
    return [
        name for name in os.listdir(a_dir) if os.path.isdir(os.path.join(a_dir, name))
    ]


services = set(get_immediate_subdirectories(".")).difference(
    set(["ci", "examples", ".git"])
)

for s in services:
    print("Generating:", s)
    print()
    print("### Sidecar Environment Variable Configuration")
    print(gen_docs(s))
