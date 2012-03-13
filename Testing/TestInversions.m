function  TestInversions(  )
% Performs multiple inversion tests

    Files = {'Arithmetic','billie','Cafe_short','chirpfrom1000', ...
        'Jack','pizz','Quartet','Traffic_short'};
    windows = [256, 512, 1024, 2048];
    laps = [2, 4, 8];
    its = [10, 50, 500];
    
    fid = fopen('Inversion_Results.csv','w');
    fprintf(fid,'File,Window,Overlap,Iterations,ODG\n');
    
    for iFile = 1:length(Files)
       for iwin = 1:length(windows)
          for ilap = 1: length(laps)
              inc = windows(iwin)/laps(ilap);
              for iit = 1: length(its)
                 ODG = TestInversion(Files{iFile}, inc, windows(iwin), its(iit));
                 
                 fprintf(fid, strcat(Files{iFile}, sprintf(', %4d, %1d, %3d, %5.2f', ...
                         windows(iwin),laps(ilap),its(iit),ODG)));
                 fprintf(fid,'\n');
                 
              end
          end
       end
    end
    
    fclose(fid);

end

