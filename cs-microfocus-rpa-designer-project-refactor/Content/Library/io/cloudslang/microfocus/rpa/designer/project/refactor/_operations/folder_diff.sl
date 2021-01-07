########################################################################################################################
#!!
#! @description: Recursively compares all foldes and files in two given folders and their subfolders (original_folder, workspace_folder) and return five lists:
#!               - list of all newly created folders (the ones that are missing from original_folder)
#!               - list of all removed folders (he ones that are missing from the workspace_folder)
#!               - list of all newly created files (the ones that are missing from original_folder)
#!               - list of all changed files (the ones present in both folders but having different content)
#!               - list of all removed files (the ones that are missing from the workspace_folder)
#!
#! @input original_folder: Folder containing files before making changes
#! @input workspace_folder: Folder containing files on which refactoring has been applied
#!
#! @output created_folders: List of folders missing from the original_folder
#! @output deleted_folders: List of folders missing from the workspace_folder
#! @output created_files: List of files missing from the original_folder
#! @output changed_files: List of files present in both folders and having different content
#! @output deleted_files: List of files missing from the workspace_folder
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: folder_diff
  inputs:
    - original_folder
    - workspace_folder
  python_action:
    use_jython: false
    script: "import filecmp\r\nimport os\r\n\r\ndef get_files(folder):\r\n    folders = set()\r\n    files_list = []\r\n    prefix_len = len(folder)+1        # remove also ending /\r\n    for root, dir, files in os.walk(folder):\r\n        relative_root = root[prefix_len:].replace(os.sep, '/')\r\n        folders.add(relative_root)\r\n        files_list += [relative_root+'/'+x for x in files]\r\n    return folders, files_list\r\n\r\n#def execute(original_folder, workspace_folder, projects_files):\r\ndef execute(original_folder, workspace_folder):\r\n    original_folders, original_files = get_files(original_folder)\r\n    original_files = set(original_files)                # convert to set\r\n    workspace_folders, workspace_files = get_files(workspace_folder)\r\n\r\n    created_files = []\r\n    changed_files = []\r\n    for w_file in workspace_files:\r\n        if w_file in original_files:\r\n            original_files.remove(w_file)\r\n            if not filecmp.cmp(original_folder+os.sep+w_file, workspace_folder+os.sep+w_file, shallow=False):\r\n                changed_files.append(w_file)\r\n        else:\r\n            created_files.append(w_file)\r\n    deleted_files = list(original_files)\r\n    created_folders = workspace_folders - original_folders\r\n    deleted_folders = original_folders - workspace_folders\r\n\r\n    #optimize \r\n    #   -> out of deleted folders, keep only root folders; e.g. from ['/root','/root/child'] -> ['/root']\r\n    deleted_folders_opt = []\r\n    for f in sorted(deleted_folders):\r\n        skip = False\r\n        for fo in deleted_folders_opt:\r\n            if f.startswith(fo):\r\n                skip = True\r\n                break\r\n        if not skip:\r\n            deleted_folders_opt.append(f)\r\n\r\n    #optimize \r\n    #   -> filter out deleted files that belong to any deleted folder\r\n    deleted_files_opt = []\r\n    for f in deleted_files:\r\n        skip = False\r\n        for fo in deleted_folders_opt:\r\n            if f.startswith(fo):\r\n                skip = True\r\n                break\r\n        if not skip:\r\n            deleted_files_opt.append(f)\r\n\r\n    # projects_files = eval(projects_files)\r\n    # deleted_folder_ids = []\r\n    # deleted_file_ids = []\r\n    # changed_file_ids = []\r\n    # for folder in deleted_folders_opt:\r\n    #     v = projects[0].folders.get(folder)\r\n    #     folder_id = v.split(':')[1]\r\n    #     deleted_folder_ids.append(folder_id)\r\n        \r\n        \r\n    \r\n\r\n    return {\r\n        'created_folders' : ','.join(sorted(created_folders)),  #sort folders to create them in order (from parent to children)\r\n        'deleted_folders' : ','.join(deleted_folders_opt),      # optimized\r\n        'created_files' : ','.join(sorted(created_files)),      #sort files to create them in order (from parent to children)\r\n        'changed_files' : ','.join(changed_files),\r\n        'deleted_files' : ','.join(deleted_files_opt)}          # optimized"
  outputs:
    - created_folders: '${created_folders}'
    - deleted_folders: '${deleted_folders}'
    - created_files: '${created_files}'
    - changed_files: '${changed_files}'
    - deleted_files: '${deleted_files}'
  results:
    - SUCCESS
