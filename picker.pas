unit picker;

interface
type
   TSubjectType = (NA, Phy, Chem, Bio, VA, Geog, BA, Econ, CHist, Hist, Music, CLit, ICT);
   function sexPicker(const x, y, colour: integer): char;
   function gradePicker(const x, y, first, last, colour: integer): integer;
   function electivePicker(const x, y, colour: integer): TSubjectType;
   function colourPicker(const x, y, colour: integer): integer;

implementation
uses crt;

function toString(const subject: TSubjectType): string[20];
begin
   case subject of
         NA   : toString := '---';
         Phy  : toString := 'Physics';
         Chem : toString := 'Chemistry';
         Bio  : toString := 'Biology';
         VA   : toString := 'Visual Art';
         Geog : toString := 'Geography';
         BA   : toString := 'BAFS';
         Econ : toString := 'Economics';
         CHist: toString := 'Chinese History';
         Hist : toString := 'History';
         Music: toString := 'Music';
         CLit : toString := 'Chinese Literature';
         ICT  : toString := 'ICT';
   end;
end;

function toStringColour(const cl: integer): string[20];
begin
   case cl of
      1:  toStringColour := 'Blue';
      2:  toStringColour := 'Green';
      3:  toStringColour := 'Cyan';
      4:  toStringColour := 'Red';
      5:  toStringColour := 'Magenta';
      6:  toStringColour := 'Brown';
   end;
end;

function toSubjectType(const subject: integer): TSubjectType;
begin
   case subject of
         1 : toSubjectType := NA;
         2 : toSubjectType := Phy;
         3 : toSubjectType := Chem;
         4 : toSubjectType := Bio;
         5 : toSubjectType := VA;
         6 : toSubjectType := Geog;
         7 : toSubjectType := BA;
         8 : toSubjectType := Econ;
         9 : toSubjectType := CHist;
         10: toSubjectType := Hist;
         11: toSubjectType := Music;
         12: toSubjectType := CLit;
         13: toSubjectType := ICT;
   end;
end;

function gradeToString(const grade: integer): string[3];
begin
    case grade of
       0: gradeToString := '---';
       1..5: str(grade, gradeToString);
       6: gradeToString := '5*';
       7: gradeToString := '5**';
    end;
end;

function sexPicker(const x, y, colour: integer): char;
var
   key: char;
   sex: integer;
   
procedure sexPickerScr(const choice, cx, cy, colour: integer);
const
   MALE = ' M ';
   FEMALE = ' F ';
begin
   window(cx, cy, cx + 3, cy + 1);
   textColor(White);
   textBackground(Black);
   clrscr;
   lowvideo;
   if choice = 1
   then begin
           textBackground(colour);
           writeln(MALE);
           textBackground(Black);
           write(FEMALE);
        end
   else begin
           textBackground(Black);
           writeln(MALE);
           textBackground(colour);
           write(FEMALE);
        end;
end;

begin
   cursoroff;
   sex := 1;
   sexPickerScr(sex, x, y, colour);
   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #72: sex := sex - 1;
                 #80: sex := (sex + 1) mod 2;
              end;
           end;
      if sex = 0 then sex := 2;
      sexPickerScr(sex, x, y, colour);
   until key = #13;
   window(x, y, x + 3, y + 1);              //close view
   textBackground(Black);
   clrscr;
   case sex of
      1: sexPicker := 'M';
      2: sexPicker := 'F';
   end;
end;

function gradePicker(const x, y, first, last, colour: integer): integer;    //first and last must be between 0-7
var
   key: char;
   grade: integer;
   
procedure gradePickerScr(const choice, cx, cy, startgr, endgr, colour: integer);
var
   grArr: array[0..7] of string[3];
   i: integer;
begin
   for i := startgr to endgr do
      grArr[i] := gradeToString(i);
   window(cx, cy, cx + 3, cy + endgr + 1);
   textBackground(Black);
   textColor(White);
   clrscr;
   lowvideo;
   for i := startgr to endgr do begin
      if choice = i then
         textBackground(colour)
      else
         textBackground(Black);
      writeln(grArr[i]);
   end;
end;

begin
   cursoroff;
   grade := first;
   gradePickerScr(grade, x, y, first, last, colour);
   repeat
      key := readkey;
      if (key = #0) and (key <> #27) then
      begin
         key := readkey;
         case key of
            #72: grade := grade - 1;
            #80: grade := grade + 1;
         end;
      end;
      if grade = first - 1 then grade := last;
      if grade = last + 1 then grade := first;
      gradePickerScr(grade, x, y, first, last, colour);
   until key = #13;
   window(x, y, x + 3, y + last + 1);             //close view
   textBackground(Black);
   clrscr;
   gradePicker := grade;
end;

function electivePicker(const x, y, colour: integer): TSubjectType;
var
   key: char;
   eltve: integer;
   
procedure electivePickerScr(const choice, cx, cy, colour: integer);
var
   elArr: array[1..13] of string[20];
   i: integer;
begin
   for i := 1 to 13 do
      elArr[i] := toString(toSubjectType(i));
   window(cx, cy, cx + 20, cy + 13);
   textBackground(Black);
   textColor(White);
   clrscr;
   lowvideo;
   for i := 1 to 13 do begin
      if choice = i then
         textBackground(colour)
      else
         textBackground(Black);
      writeln(elArr[i]);
   end;
end;

begin
   cursoroff;
   eltve := 1;
   electivePickerScr(eltve, x, y, colour);
   repeat
      key := readkey;
      if (key = #0) and (key <> #27) then
      begin
         key := readkey;
         case key of
            #72: eltve := eltve - 1;
            #80: eltve := (eltve + 1) mod 13;
         end;
      end;
      if eltve = 0 then eltve := 13;
      electivePickerScr(eltve, x, y, colour);
   until key = #13;
   window(x, y, x + 20, y + 13);                //close view
   textBackground(Black);
   clrscr;
   electivePicker := toSubjectType(eltve);
end;

function colourPicker(const x, y, colour: integer): integer;
var
   key: char;
   cl: 1..6;

procedure colorPickerScr(const choice, cx, cy, colour: integer);
var
   i: integer;
begin
   window(cx, cy, cx + 18, cy + 6);
   textBackground(Black);
   textColor(White);
   clrscr;
   lowvideo;
   for i := 1 to 6 do begin
      if choice = i then
         textBackground(colour)
      else
         textBackground(Black);
      writeln(toStringColour(i));
   end;
end;

procedure colorBox(choice: integer);
begin
   textBackground(choice);
   window(50, 6, 61, 6);
   write('  PREVIEW  ');
end;

begin
   cursoroff;
   cl := 1;
   colorPickerScr(cl, x, y, colour);
   colorBox(cl);
   repeat
      key := readkey;
      if (key = #0) and (key <> #27) then
      begin
         key := readkey;
         case key of
            #72: cl := cl - 1;
            #80: cl := cl + 1;
         end;
      end;
      if cl = 0 then cl := 6;
      if cl > 6 then cl := 1;
      colorPickerScr(cl, x, y, colour);
      colorBox(cl);
   until key = #13;
   window(x, y, x + 18, y + 6);                //close view
   textBackground(Black);
   clrscr;
   colourPicker := cl;
end;

end.
