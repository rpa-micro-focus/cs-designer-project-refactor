########################################################################################################################
#!!
#! @description: Starts refactoring session or continues in an already started session. It checks out the project of the given user.
#!
#! @input session_token: Do no provide anything when starting a new session; type the session token when continuing in an already started session.
#! @input ws_user: All files from the workspace of this user will be downloaded
#! @input ws_password: Workspace user password
#! @input ws_tenant: Which tenant the user belongs to
#!
#! @output new_session_token: Returns the given or newly created sesstion token (if a new session has started)
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: download_project
  inputs:
    - session_token:
        required: false
    - ws_user
    - ws_password:
        required: true
        sensitive: true
    - ws_tenant:
        required: false
  workflow:
    - is_token_given:
        do:
          io.cloudslang.base.utils.is_null:
            - variable: '${session_token}'
        navigate:
          - IS_NULL: uuid_generator
          - IS_NOT_NULL: put_session_properties
    - get_token:
        do:
          io.cloudslang.microfocus.rpa.designer.authenticate.get_token:
            - ws_user: '${ws_user}'
            - ws_password: '${ws_password}'
            - ws_tenant: '${ws_tenant}'
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
          - SUCCESS: download_projects_files
    - clone_folder:
        do:
          io.cloudslang.base.filesystem.clone_folder:
            - existing_folder: "${session_folder+'/original'}"
            - cloned_folder: "${session_folder+'/workspace'}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - uuid_generator:
        do:
          io.cloudslang.base.utils.uuid_generator: []
        publish:
          - session_token: '${new_uuid[:5]}'
        navigate:
          - SUCCESS: put_session_properties
    - put_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.put_session_properties:
            - session_token: '${session_token}'
            - ws_user: '${ws_user}'
            - ws_password: '${ws_password}'
        publish:
          - session_folder: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user}"
        navigate:
          - SUCCESS: get_token
          - FAILURE: on_failure
    - download_projects_files:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.download_projects_files:
            - ws_id: '${ws_id}'
            - folder_path: "${session_folder+'/original'}"
        publish:
          - projects_details
        navigate:
          - FAILURE: on_failure
          - SUCCESS: clone_folder
  outputs:
    - new_session_token: '${session_token}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_token_given:
        x: 21
        'y': 96
      get_token:
        x: 299
        'y': 89
      get_ws_id:
        x: 399
        'y': 270
      clone_folder:
        x: 608
        'y': 270
        navigate:
          1acbb6b9-86bf-ba05-0bfe-e5fe77dbe887:
            targetId: d18a5abe-cad3-e570-25b6-4495b48a7331
            port: SUCCESS
      uuid_generator:
        x: 20
        'y': 267
      put_session_properties:
        x: 183
        'y': 263
      download_projects_files:
        x: 522
        'y': 104
    results:
      SUCCESS:
        d18a5abe-cad3-e570-25b6-4495b48a7331:
          x: 733
          'y': 105
