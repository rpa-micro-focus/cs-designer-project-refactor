########################################################################################################################
#!!
#! @description: Checks in all changes made in all checked out projects (that belong to the given session) and finishes the session (unless keep_session is true).
#!
#! @input keep_session: If true, all changes are committed but session is not ended so additional changes can be made
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: upload_projects
  inputs:
    - session_token
    - keep_session:
        required: false
  workflow:
    - get_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.get_session_properties:
            - session_token: '${session_token}'
        publish:
          - ws_users
          - properties
        navigate:
          - SUCCESS: loop_users
          - FAILURE: on_failure
    - loop_users:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${ws_users}'
        publish:
          - ws_user: '${result_string}'
        navigate:
          - HAS_MORE: get_token
          - NO_MORE: is_keep_session
          - FAILURE: on_failure
    - folder_diff:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.folder_diff:
            - original_folder: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/original'}"
            - workspace_folder: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace'}"
            - ws_user: '${ws_user}'
            - properties: '${properties}'
        publish:
          - created_files
          - changed_files
          - deleted_files
          - ws_password: '${eval(properties).get(ws_user)}'
          - created_folders
          - deleted_folders
        navigate:
          - SUCCESS: is_folders_to_delete
    - get_projects:
        do:
          io.cloudslang.microfocus.rpa.designer.project.get_projects:
            - ws_id: '${ws_id}'
        publish:
          - projects_json
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_projects_files
    - get_token:
        do:
          io.cloudslang.microfocus.rpa.designer.authenticate.get_token:
            - ws_user: '${ws_user}'
            - ws_password: '${ws_password}'
        publish:
          - token
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_ws_id
    - get_ws_id:
        do:
          io.cloudslang.microfocus.rpa.designer.workspace.get_ws_id: []
        publish:
          - ws_id
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_projects
    - logout:
        do:
          io.cloudslang.microfocus.rpa.designer.authenticate.logout: []
        navigate:
          - SUCCESS: loop_users
    - get_projects_files:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.get_projects_files:
            - projects_json: '${projects_json}'
        publish:
          - projects_files
        navigate:
          - SUCCESS: folder_diff
          - FAILURE: on_failure
    - is_folders_to_delete:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(deleted_folders)>0)}'
        navigate:
          - 'TRUE': delete_folder
          - 'FALSE': is_files_to_delete
    - is_files_to_delete:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(deleted_files)>0)}'
        navigate:
          - 'TRUE': delete_file
          - 'FALSE': is_folders_to_create
    - upload_file:
        loop:
          for: file in changed_files
          do:
            io.cloudslang.microfocus.rpa.designer.project.upload_file:
              - token: '${token}'
              - file_id: "${eval(projects_files)[0].get('files').get(file).split(':')[1]}"
              - file_path: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+\"/\"+session_token+\"/\"+ws_user+\"/workspace/\"+file}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_files_to_create
    - is_files_to_change:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(changed_files)>0)}'
        navigate:
          - 'TRUE': upload_file
          - 'FALSE': is_files_to_create
    - is_files_to_create:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(created_files)>0)}'
        navigate:
          - 'TRUE': create_file
          - 'FALSE': logout
    - is_folders_to_create:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${str(len(created_folders)>0)}'
        navigate:
          - 'TRUE': create_folder_add_record
          - 'FALSE': is_files_to_change
    - create_file:
        loop:
          for: file in created_files
          do:
            io.cloudslang.microfocus.rpa.designer.project.create_file:
              - token: '${token}'
              - folder_id: "${eval(projects_files)[0].get('folders').get(file[0:file.rfind('/')]).split(':')[1]}"
              - file_path: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace/'+file}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: logout
    - delete_folder:
        loop:
          for: folder in deleted_folders
          do:
            io.cloudslang.microfocus.rpa.designer.project.delete_element:
              - token: '${token}'
              - element_id: "${eval(projects_files)[0].get('folders').get(folder).split(':')[1]}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_files_to_delete
    - delete_file:
        loop:
          for: file in deleted_files
          do:
            io.cloudslang.microfocus.rpa.designer.project.delete_element:
              - token: '${token}'
              - element_id: "${eval(projects_files)[0].get('files').get(file).split(':')[1]}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_folders_to_create
    - is_keep_session:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${keep_session}'
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': delete_session_properties
    - delete_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.delete_session_properties:
            - session_token: '${session_token}'
        navigate:
          - SUCCESS: delete
          - FAILURE: on_failure
    - delete:
        do:
          io.cloudslang.base.filesystem.delete:
            - source: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - create_folder_add_record:
        loop:
          for: folder in created_folders
          do:
            io.cloudslang.microfocus.rpa.designer.project.refactor._operations.create_folder_add_record:
              - token: '${token}'
              - folder: '${folder}'
              - projects_files: '${projects_files}'
          break:
            - FAILURE
          publish:
            - projects_files: '${new_projects_files}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_files_to_change
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_folders_to_delete:
        x: 1005
        'y': 337
      delete_folder:
        x: 1008
        'y': 525
      is_files_to_create:
        x: 276
        'y': 338
      get_projects:
        x: 716
        'y': 208
      get_session_properties:
        x: 22
        'y': 205
      logout:
        x: 92
        'y': 339
      delete:
        x: 632
        'y': 20
        navigate:
          43647429-d7c7-6b95-8d09-97b916d106c8:
            targetId: 44e88453-9627-7953-988b-05eb59d64832
            port: SUCCESS
      loop_users:
        x: 225
        'y': 203
      delete_session_properties:
        x: 819
        'y': 92
      delete_file:
        x: 821
        'y': 526
      get_token:
        x: 384
        'y': 209
      is_keep_session:
        x: 102
        'y': 93
        navigate:
          fdf9341b-072b-6cb6-06e3-1939bebeed2b:
            targetId: 44e88453-9627-7953-988b-05eb59d64832
            port: 'TRUE'
      is_folders_to_create:
        x: 646
        'y': 338
      is_files_to_delete:
        x: 822
        'y': 337
      get_ws_id:
        x: 542
        'y': 209
      folder_diff:
        x: 1090
        'y': 207
      is_files_to_change:
        x: 467
        'y': 335
      upload_file:
        x: 468
        'y': 526
      get_projects_files:
        x: 914
        'y': 207
      create_folder_add_record:
        x: 648
        'y': 526
      create_file:
        x: 272
        'y': 528
    results:
      SUCCESS:
        44e88453-9627-7953-988b-05eb59d64832:
          x: 346
          'y': 20
