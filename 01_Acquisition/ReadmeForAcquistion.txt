Quick Description of folders (in alphabetical order).
_____________________________________________________
1) auto_opening_bash_shortcuts: short bash script opening the specific matlab GUI of interest were create and shortcut to those were place on our desktop.
2) Callibratoin_Charactirazation: During the callibration and characterization procedures, a 2D or 3D raster of the FOV is performed (with arena\rectiles\resolution target\spheres\etc). The script in this folder enable that in an automated way, along with exporting the acquired images in "montage"-friendly ways.
3) Functions: Main functions that the GUIs are calling. Of Special intereste are:
3.1) worker_scipts(path): The main scripts sent to the workers. Note that some of this scripts are hardware specific and thus require installed the SDK of the manufacturers (are based on examples from there).
3.2) read_most_recent_fluoroANDreflection.m: read and the most recently acquired reflection and fluorescence images. Used extensivly for both online\offline previewing and the guiding the acquition (e.g using the more recent reflection imagine as input ot the tracking algorithm etc).
3.3) RegisterGalvor2Reflection_FOR_GUI.m: An important initialization step. The user has to click in several (>4) points in a static sample in the 1x FOV (e.g. callibration target) and then with the help of the joystick indicate which are the correspodning galvo-locations. This pairs of coordinates are used to defene the transformation matrix used during the tracking.
3.4) mouseinput_timeout.m : although the system is automated, during the development phase it is important to give the user manual override option. This function allows the user click on the live-preview of the 1x channel and move the galvos at the corresponding positition, bypassing the online tracking.
4) GUI_version: The two main guis (acquisition control) and preview (used for both online preview during acquisition and checking previewsly acquired dataset)


*Note1: "ZT" (Zebratracker) and "ZBTRC" (NeuBTRacker) are all acronyms for the same system, used at different development phases

