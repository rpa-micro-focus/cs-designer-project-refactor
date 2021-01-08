A. Features
-----------
  - can _rename_ Flows, Operations, UI Activities or System Properties (Elements)
  - can _rename_ Namespaces (folders)
  - can _move_ Elements to another Namespaces (folders)
  - can refactor on _multiple projects_ at once
  - renames not only the particular Element but also _all its references_

B. Requirements
---------------
  - At least OO / RPA 2020.02 (with Python 3.8 support)
  - Following CPs deployed:
    - CS Base (https://marketplace.microfocus.com/itom/content/cloudslang-base-content)
	- cs-base-te-addon (https://github.com/rpa-micro-focus/cs-base-te-addon/releases/latest)
      - extends CS Base CP
      - depends on the above
	- cs-microfocus-rpa (https://github.com/rpa-micro-focus/rpa-rpa/releases/latest)
      - content managing an OO/RPA instance (including Workflow Designer project)
      - depends on the above
	- cs-designer-project-refactor (https://github.com/rpa-micro-focus/cs-designer-project-refactor/releases/latest)
      - content to refactor	Workflow Designer project
	  - depends on the above
    
C. How to Use
-------------
I. Session Initialization (project check-out)
=========================
  1. Run **download_project** flow
     - provide Designer workspace user / password 
     - wait for getting the project replicated from Designer Workspace to OO worker node local folder
     - obtain **Session Token** (as the flow output)
  2. (optional) Run download_project flow again
     - provide another Desginer workspace user / password
     - provide the same Session Token as before
  3. (optional) Run download_project flow as many times as needed
     - each time provide the same Session Token
     - each time download another user's project files


II. Refactoring (of all projects belonging to the session)
==========================================================
  4. Run **move_file**, **move_folder**, **move_property_file** or **rename_property flow** to refactor your projects
     - provide **Session Token** obtained in the first step
     - **move_file** renames the given Flow/Operation/Activity to another file (changing name) or folder (changing namespace) or both
     - **move_folder** renames the folder to another folder thus changing the namespace of all the Flows/Operations/Activities under the original folder
     - **move_property_file** moves the file with System Properties to another folder thus changing the namespace of all System Properties in the file
     - **rename_property changes** name of one particular System Property (while keeping all the other)
  5. Run any of the flow above as many times as needed
     - all refactoring is done on all checked-out projects
     - all changes are made on the OO worker node local file system only
     - if your project is linked with a GIT repo, nothing is commited/pushed to the repo yet (you have still the choice of dropping your changes with no impact)
   
III. Closing the Session (projects check-in)
============================================
  6. Run **upload_projects**
     - provide **Session Token** obtained in the first step
     - all your changes (so far made on the OO worker node local file system only) will be replicated to the particular user's workspace in Designer
     - your Session is over and all data (user passwords, user project files) are removed from the OO worker node file system
         - unless you provide input parameter _keep_session = true_; in such a case, you may continue with your refactorings to run flows as in chapter II. (this option is good to verify refactoring made so far; see chapter IV.)
     - if your project is linked with a GIT repo, nothing is commited/pushed to the repo yet (you have still the choice of dropping your changes with no impact)
	
IV. Verify refactored projects
==============================
  7. Login to user workspace in Workflow Designer (or refresh the page in browser)
  8. Verify no content is red
  9. (Mandatory) Debug your content to verify nothing got broken
      - repeat that for all refactored projects
  10. Commit / push your changes to the linked GIT repo

D. Limitations
--------------
  - _does not rename steps_ (which usually take their names after the Elements)
  - **is not secure** (do not use in production or shared environment!!)
    - during the session, the user credentials are insecurely stored on the OO worker node file system
  - will not work when multiple worker nodes are used
  - when multiple projects are stored in a single Workspace (rare situation), it only refactors files in the very first project
    - still, multiple projects (each project belonging to a different user workspace) is supported
  - all the user workspaces should belong to the same Tenant
  - tested only on WD generated projects (may not work on content written in CS using a text editor); e.g. imports do not work
  - project check-out and check-in may be a pretty slow operation (on the other hand, project refactoring is pretty fast operation!)
	
Please, let the author (mailto:petr.panuska@microfocus.com) know your feedback and if any of the limitations needs to be addressed!
