#! /usr/bin/env python3

import os
import sys
from shutil import copyfile
from lxml import etree as ET


class IsCountsCorrect():
    def __init__(self, alias):
        list_of_etrees = IsCountsCorrect.make_etrees_of_Elems_In(alias)
        root_count = IsCountsCorrect.get_root_count_from_etrees(list_of_etrees)
        root_compounds = IsCountsCorrect.name_root_compounds(list_of_etrees)
        simples = root_count - len(root_compounds)
        compounds = 0
        for parent in root_compounds:
            compounds += IsCountsCorrect.count_child_pointers(alias, parent)
            compounds += 1  # we cound parent as 1 item here.

        print('Count Simples xmls:', simples)
        print('Count Compounds xmls', compounds)
        if simples == IsCountsCorrect.count_observed_simples(alias):
            print('simples match')
        else:
            print("BIG DEAL:  Simples Don't Match")
        if compounds == IsCountsCorrect.count_observed_compounds(alias):
            print('compounds match')
        else:
            print("BIG DEAL:  Compounds Don't Match")

    @staticmethod
    def make_etrees_of_Elems_In(alias):
        input_dir = os.path.abspath('Cached_Cdm_files/{}'.format(alias))
        elems_files = ["{}/{}".format(input_dir, i) for i in os.listdir(input_dir) if ('Elems_in_Collection' in i) and ('.xml' in i)]
        return [ET.parse(i) for i in elems_files]

    @staticmethod
    def get_root_count_from_etrees(list_of_etrees):
        set_total_at_root_level = {int(elems_etree.find('./pager/total').text) for elems_etree in list_of_etrees}
        if len(set_total_at_root_level) == 1:
            return set_total_at_root_level.pop()
        else:
            print('BIG DEAL:  either Elems_in_Collection has mismatched number of total counts, or an Elems_in is unreadable')
            return False

    @staticmethod
    def name_root_compounds(list_of_etrees):
        compound_pointers = []
        for i in list_of_etrees:
            for elem in i.findall('.//record/filetype'):
                if elem.text == 'cpd':
                    pointers = {p.text for p in elem.itersiblings(preceding=True) if p.tag == 'pointer'}.union(
                               {p.text for p in elem.itersiblings() if p.tag == 'pointer'})
                    dmrecords = {p.text for p in elem.itersiblings(preceding=True) if p.tag == 'dmrecord'}.union(
                                {p.text for p in elem.itersiblings() if p.tag == 'dmrecord'})
                    if pointers:
                        compound_pointers.append(pointers.pop())
                    elif dmrecords:
                        compound_pointers.append(dmrecords.pop())
        return compound_pointers

    @staticmethod
    def count_child_pointers(alias, cpd_pointer):
        structure_file = os.path.abspath('Cached_Cdm_files/{}/Cpd/{}_cpd.xml'.format(alias, cpd_pointer))
        structure_etree = ET.parse(structure_file)
        child_pointers = [i.text for i in structure_etree.findall('./page/pageptr')]
        return len(child_pointers)

    @staticmethod
    def count_observed_simples(alias):
        for root, dirs, files in os.walk(os.path.abspath('output'.format(alias))):
            if root.split('/')[-1] == '{}_simple'.format(alias):
                output_dir = '{}/original_structure/'.format(root)
                for root, dirs, files in os.walk(output_dir):
                    return len([i for i in files if ".xml" in i])

    @staticmethod
    def count_observed_compounds(alias):
         for root, dirs, files in os.walk(os.path.abspath('output'.format(alias))):
            if root.split('/')[-1] == '{}_compound'.format(alias):
                output_dir = '{}/original_structure/'.format(root)
                compounds_count = 0
                for root, dirs, files in os.walk(output_dir):
                    compounds_count += len([i for i in files if i == "MODS.xml"])
                return compounds_count


class PullInBinaries():
    '''
    usage is:
        from base directory of mik,
        after mods successfully created,
        (for either simple or compound or both),
        shellcommand:
                      'python3 pull_in_binaries.py p16313coll13'

       result is:
        for each mods item in the output/alias_simpleorcompound/original_structure/ directory,
        the matching binary will be pulled from mik/Cached_Cdm_files/alias/

       a tiny error message will print on the shell screen if no matching file is found
    '''

    def __init__(self, alias):
        sourcefiles_paths = PullInBinaries.makedict_sourcefiles(alias)
        simplexmls_list = PullInBinaries.makelist_simpleoutfolderxmls(alias)
        compoundxmls_list = PullInBinaries.makelist_compoundoutfolderxmls(alias)
        for filelist in (simplexmls_list, compoundxmls_list):
            for kind, outroot, pointer in filelist:
                if pointer not in sourcefiles_paths:
                    if ("_compound" in outroot) and (outroot.split('/')[-2] == "original_structure"):
                        continue  # root of cpd is expected to have no binary
                    else:
                        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print("{}.xml may not have a matching binary".format(pointer))
                        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                if PullInBinaries.is_binary_in_output_dir(kind, outroot, pointer):
                    continue
                if pointer not in sourcefiles_paths:
                    continue
                sourcepath, sourcefile = sourcefiles_paths[pointer]
                PullInBinaries.copy_binary(kind, sourcepath, sourcefile, outroot, pointer)

    @staticmethod
    def makedict_sourcefiles(alias):
        sourcefiles_paths = dict()
        input_dir = 'Cached_Cdm_files/{}'.format(alias)
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                if file.split('.')[-1] in ('jp2', 'mp4', 'mp3', 'pdf'):
                    alias = file.split('.')[0]
                    sourcefiles_paths[alias] = (root, file)
        return sourcefiles_paths

    @staticmethod
    def makelist_simpleoutfolderxmls(alias):
        xml_filelist = []
        subfolder = "output/{}_simple/original_structure".format(alias)
        for root, dirs, files in os.walk(subfolder):
            for file in files:
                if '.xml' in file:
                    pointer = file.split('.')[0]
                    xml_filelist.append(('simple', root, pointer))
        return xml_filelist

    @staticmethod
    def makelist_compoundoutfolderxmls(alias):
        xml_filelist = []
        subfolder = "output/{}_compound/original_structure".format(alias)
        for root, dirs, files in os.walk(subfolder):
            for file in files:
                if file == 'MODS.xml':
                    pointer = root.split('/')[-1]
                    xml_filelist.append(('compound', root, pointer))
        return xml_filelist

    @staticmethod
    def is_binary_in_output_dir(kind, root, pointer):
        acceptable_binary_types = ('mp3', 'mp4', 'jp2', 'pdf')
        if kind == 'simple':
            for filetype in acceptable_binary_types:
                if os.path.isfile('{}/{}.{}'.format(root, pointer, filetype)):
                    return True
        if kind == 'compound':
            for filetype in acceptable_binary_types:
                if os.path.isfile('{}/{}/OBJ.{}'.format(root, pointer, filetype)):
                    return True
        return False

    @staticmethod
    def copy_binary(kind, sourcepath, sourcefile, outroot, pointer):
        if kind == 'simple':
            copyfile("{}/{}".format(sourcepath, sourcefile), "{}/{}".format(outroot, sourcefile))
        elif kind == 'compound':
            copyfile("{}/{}".format(sourcepath, sourcefile), "{}/OBJ.{}".format(outroot, sourcefile.split('.')[-1]))


class MakeStructureFile():
    def __init__(self, alias):
        for root, dirs, files in os.walk('output'):
            if 'structure.cpd' in files:
                parent = root.split("/")[-1]
                xml_header = '<?xml version="1.0" encoding="utf-8"?>'
                new_etree = ET.Element("islandora_compound_object", title=parent)

                old_etree = ET.parse("{}/structure.cpd".format(root))
                for i in old_etree.findall('.//pageptr'):
                    # print('child is: ', i.text)
                    new_etree.append(ET.Element('child', content=i.text))

                with open('{}/structure.xml'.format(root), 'wb') as f:
                    f.write(ET.tostring(new_etree, encoding="utf-8", xml_declaration=True, pretty_print=True))

if __name__ == '__main__':
    alias = sys.argv[1]
    PullInBinaries(alias)
    MakeStructureFile(alias)
    IsCountsCorrect(alias)
