function pars=extractpars(vars,default)
% This is a helper function that allows simple parsing of command line
% parameters.

if(nargin<2)
  default=[];
end

pars=default;
if(length(vars)==1)
 p=vars{1};
 s=fieldnames(p);
 for i=1:length(s)
   eval(['pars.' s{i} '=p.' s{i}]);
 end;     

else

 for i=1:2:length(vars)
  if(ischar(vars{i}))
    if(i+1>length(vars)) error(sprintf('Parameter %s has no value\n',vars{i}));else val=vars{i+1};end;
    if(ischar(val))
     eval(['pars.' vars{i} '=''' val ''';']);
    else
     eval(['pars.' vars{i} '=val;']);
    end;
  end;
 end;

end;

