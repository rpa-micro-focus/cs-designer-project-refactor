########################################################################################################################
#!!
#! @description: Downloads all files in the given workspace (belonging to the very first project) to the given folder.
#!
#! @input ws_id: Workspace to be downloaded
#! @input folder_path: Path where will be the files saved
#!
#! @output projects_details: List of projects with a list of flows/operations/properties the project consists of (as files)
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
flow:
  name: download_projects_files
  inputs:
    - ws_id
    - folder_path
  workflow:
    - get_projects:
        do:
          io.cloudslang.microfocus.rpa.designer.project.get_projects:
            - ws_id: '${ws_id}'
        publish:
          - projects_json
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_projects_files
    - create_folder_tree:
        loop:
          for: folder in folders
          do:
            io.cloudslang.base.filesystem.create_folder_tree:
              - folder_name: "${folder_path+'/'+folder}"
          break: []
        navigate:
          - SUCCESS: has_files
          - FAILURE: has_files
    - get_projects_files:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.get_projects_files:
            - projects_json: '${projects_json}'
        publish:
          - projects_files
          - folders: "${','.join(eval(projects_files)[0].get('folders').keys())}"
          - files: "${str(eval(projects_files)[0].get('files'))}"
        navigate:
          - SUCCESS: has_folders
          - FAILURE: on_failure
    - has_folders:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(folders)>0)}'
        navigate:
          - 'TRUE': create_folder_tree
          - 'FALSE': has_files
    - has_files:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(eval(files))>0)}'
        navigate:
          - 'TRUE': download_file
          - 'FALSE': SUCCESS
    - download_file:
        loop:
          for: 'file_path,id in eval(files)'
          do:
            io.cloudslang.microfocus.rpa.designer.project.download_file:
              - ws_id: '${ws_id}'
              - file_id: "${file_id.split(':')[1]}"
              - file_path: '${folder_path+"/"+file_path}'
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  outputs:
    - projects_details: '${projects_details}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_projects:
        x: 39
        'y': 77
      create_folder_tree:
        x: 34
        'y': 502
      get_projects_files:
        x: 240
        'y': 80
      has_folders:
        x: 35
        'y': 291
      has_files:
        x: 240
        'y': 290
        navigate:
          d888da92-55af-8662-a4fc-76b6f82d656c:
            targetId: b4dcc687-7981-f39a-78ce-69fc2d360fff
            port: 'FALSE'
      download_file:
        x: 240
        'y': 503
        navigate:
          ba19cd5a-39f9-ce89-0031-21d911338fe2:
            targetId: b4dcc687-7981-f39a-78ce-69fc2d360fff
            port: SUCCESS
    results:
      SUCCESS:
        b4dcc687-7981-f39a-78ce-69fc2d360fff:
          x: 460
          'y': 289
