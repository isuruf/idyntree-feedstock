mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DIDYNTREE_USES_IPOPT:BOOL=ON ^
    -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON ^
    -DIDYNTREE_USES_IRRLICHT:BOOL=ON ^
    -DIDYNTREE_USES_MATLAB:BOOL=OFF ^
    -DIDYNTREE_USES_PYTHON:BOOL=ON ^
    -DIDYNTREE_USES_OCTAVE:BOOL=OFF ^
    -DIDYNTREE_USES_LUA:BOOL=OFF ^
    -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF ^
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1

:: Fix Python package version
%PYTHON% replace.py -f setup.py --pre 'use_scm_version=dict(local_scheme="dirty-tag"),' --post 'version=$PKG_VERSION,'

:: Python package
%PYTHON% ^
    -m build ^
    --wheel ^
    --outdir dist ^
    --no-isolation ^
    --skip-dependency-check ^
    "-C--global-option=build_ext" ^
    "-C--global-option=--no-cmake-extension=all" ^
    .
pip install --no-deps dist/*.whl
