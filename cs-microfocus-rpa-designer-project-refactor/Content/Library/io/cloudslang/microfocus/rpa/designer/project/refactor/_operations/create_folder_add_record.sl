namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
flow:
  name: create_folder_add_record
  inputs:
    - token
    - folder
    - projects_files
  workflow:
    - create_folder:
        do:
          io.cloudslang.microfocus.rpa.designer.project.create_element:
            - token: '${token}'
            - element_name: "${folder.split('/')[-1]}"
            - element_type: FOLDER
            - folder_id: "${eval(projects_files)[0].get('folders').get(folder[0:folder.rfind('/')]).split(':')[1]}"
        publish:
          - element_id
        navigate:
          - FAILURE: on_failure
          - SUCCESS: add_folder_record
    - add_folder_record:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.add_folder_record:
            - projects_files: '${projects_files}'
            - folder_path: '${folder}'
            - folder_id: '${element_id}'
        publish:
          - new_projects_files
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - new_projects_files: '${new_projects_files}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      create_folder:
        x: 73
        'y': 96
      add_folder_record:
        x: 294
        'y': 100
        navigate:
          68c720b2-d8e2-9c60-6dcb-480eaa144b80:
            targetId: c9288968-e9fc-961f-b528-662f505adabc
            port: SUCCESS
    results:
      SUCCESS:
        c9288968-e9fc-961f-b528-662f505adabc:
          x: 486
          'y': 99
