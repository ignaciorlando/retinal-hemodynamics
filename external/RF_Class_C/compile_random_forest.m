% ********************************************************************
% * mex File compiling code for Random Forest (for linux)
% * mex interface to Andy Liaw et al.'s C code (used in R package randomForest)
% * Added by Jos?? Ignacio Orlando ( jiorlando@conicet.gov.ar )
% ********************************************************************/
function compile_random_forest
    
    % prepare folder were the object files are contained
    archstr = computer('arch');

    if ispc()
        
        if strcmp(archstr(end-1:end), '32')
            
            if exist('mexClassRF_train.mexw32', 'file')==0
            
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/win32/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/win32 -c src/rfsub.f
                end
                mex -DMATLAB -output mexClassRF_train   src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/win32/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp 
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/win32/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
                
            end
            
        else
            
            if exist('mexClassRF_train.mexw64', 'file')==0
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/win64/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/win64 -c src/rfsub.f
                end
                mex -DMATLAB -output mexClassRF_train   src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/win64/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp 
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/win64/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
                
            end
                
        end        
        
    elseif ismac()
        
        if strcmp(archstr(end-1:end), '32')
            
            if exist('mexClassRF_train.mexmaci32', 'file')==0
            
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/mac32/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/mac32 -c src/rfsub.f
                end
                mex -DMATLAB -output mexClassRF_train  src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/mac32/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp 
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/mac32/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
                
            end
                
        else
            
            if exist('mexClassRF_train.mexmaci64', 'file')==0
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/mac64/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/mac64 -c src/rfsub.f
                end
                mex -DMATLAB -output mexClassRF_train  src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/mac64/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp 
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/mac64/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
            end
        end        
        
    else
        
        if strcmp(archstr(end-1:end), '32')
            
            if exist('mexClassRF_train.mexa32', 'file')==0
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/linux32/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/linux32 -c src/rfsub.f
                end
                mex  -DMATLAB -output mexClassRF_train  src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/linux32/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp 
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/linux32/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
            end
            
        else
            
            if exist('mexClassRF_train.mexa64', 'file')==0
                % Compile the object file (if it does not exist)
                if exist('precompiled_rfsub/linux64/rfsub.o', 'file')==0
                    mex -outdir precompiled_rfsub/linux64 -c src/rfsub.f
                end
                mex -DMATLAB -output mexClassRF_train  src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/linux64/rfsub.o src/mex_ClassificationRF_train.cpp   src/rfutils.cpp %-lm -DMATLAB -O -lgfortran
                mex -DMATLAB -output mexClassRF_predict src/classRF.cpp src/classTree.cpp src/cokus.cpp precompiled_rfsub/linux64/rfsub.o src/mex_ClassificationRF_predict.cpp src/rfutils.cpp 
            end
        end  
        
    end
end
