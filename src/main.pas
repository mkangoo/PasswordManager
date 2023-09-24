//---------------------------------------------//
// |  _ \ __ _ ___ _____      _____  _ __ __| |
// | |_) / _` / __/ __\ \ /\ / / _ \| '__/ _` |
// |  __/ (_| \__ \__ \\ V  V / (_) | | | (_| |
// |_|   \__,_|___/___/ \_/\_/ \___/|_|  \__,_|

//  __  __                                   
// |  \/  | __ _ _ __   __ _  __ _  ___ _ __ 
// | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '__|
// | |  | | (_| | | | | (_| | (_| |  __/ |   
// |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_|   
//                           |___/           
//---------------------------------------------//

Program PasswordManager;

Uses 
SysUtils;

Const 
  MaxPasswords = 100;
  EncryptionKey = 42;
  FileName = 'passwords.txt';

Type 
  PasswordEntry = Record
    Name: string;
    Password: string;
  End;

Var 
  Passwords: array[1..MaxPasswords] Of PasswordEntry;
  PasswordCount: Integer;

Procedure EncryptDecrypt(Const Input: String; Var Output: String);

Var 
  i: Integer;
Begin
  SetLength(Output, Length(Input));
  For i := 1 To Length(Input) Do
    Output[i] := Chr(Ord(Input[i]) xor EncryptionKey);
End;

Procedure InitializePasswords;

Var 
  i: Integer;
Begin
  For i := 1 To MaxPasswords Do
    Begin
      Passwords[i].Name := '';
      Passwords[i].Password := '';
    End;
  PasswordCount := 0;
End;

Procedure SplitString(Const Input: String;
                      Delimiter: Char; Var Left, Right:String);

Var 
  DelimiterPos: Integer;
Begin
  DelimiterPos := Pos(Delimiter, Input);
  If DelimiterPos > 0 Then
    Begin
      Left := Copy(Input, 1, DelimiterPos - 1);
      Right := Copy(Input, DelimiterPos + 1, Length(Input) - DelimiterPos);
    End
  Else
    Begin
      Left := Input;
      Right := '';
    End;
End;

Procedure LoadPasswordsFromFile;

Var 
  FileHandle: TextFile;
  Line, TempName, TempPassword: String;
Begin
  If FileExists(FileName) Then
    Begin
      Assign(FileHandle, FileName);
      Reset(FileHandle);
      PasswordCount := 0;
      While Not EOF(FileHandle) Do
        Begin
          Inc(PasswordCount);
          If PasswordCount > MaxPasswords Then
            Begin
              Writeln('Maximum limit of passwords exceeded.');
              Exit;
            End;
          ReadLn(FileHandle, Line);
          SplitString(Line, ':', TempName, TempPassword);
          If TempName <> '' Then
            Begin
              Passwords[PasswordCount].Name := TempName;
              Passwords[PasswordCount].Password := TempPassword;
            End;
        End;

      Close(FileHandle);
    End
  Else
    Writeln('File not found. Creating a new file.');
End;

Procedure SavePasswordsToFile;

Var 
  FileHandle: TextFile;
  i: Integer;
Begin
  Assign(FileHandle, FileName);
  Rewrite(FileHandle);

  For i := 1 To PasswordCount Do
    WriteLn(FileHandle, Passwords[i].Name + ':' + Passwords[i].Password);

  Close(FileHandle);
End;

Procedure AddPassword;

Var 
  Name, Password: String;
  i: Integer;
  Choice: Char;
Begin
  Write('Enter name: ');
  Readln(Name);
  For i := 1 To PasswordCount Do
    Begin
      If Passwords[i].Name = Name Then
        Begin
          Writeln('Password with this name already exists.');
          Writeln('1. Overwrite the existing password');
          Writeln('2. Return to the main menu');
          Write('Enter your choice: ');
          Readln(Choice);
          Case Choice Of 
            '1': 
                 Begin
                   Write('Enter new password: ');
                   Readln(Password);
                   EncryptDecrypt(Password, Passwords[i].Password);
                   SavePasswordsToFile;
                   Writeln('Password updated.');
                   Exit;
                 End;
            '2': 
                 Exit;
            Else
              Writeln('Invalid choice. Returning to the main menu.');
            Exit;
          End;
        End;
    End;
  If PasswordCount < MaxPasswords Then
    Begin
      Inc(PasswordCount);
      Passwords[PasswordCount].Name := Name;
      Write('Enter password: ');
      Readln(Password);
      EncryptDecrypt(Password, Passwords[PasswordCount].Password);
      SavePasswordsToFile;
      Writeln('Password added.');
    End
  Else
    Writeln('Cannot add more passwords. Maximum limit reached.');
End;

Procedure ModifyPassword;

Var 
  Name, Password: String;
  i: Integer;
  Choice: Char;
Begin
  Write('Enter the name of the password to modify: ');
  Readln(Name);
  For i := 1 To PasswordCount Do
    Begin
      If Passwords[i].Name = Name Then
        Begin
          EncryptDecrypt(Passwords[i].Password, Password);
          Writeln('Password found for the given name:');
          Writeln('Name: ', Passwords[i].Name);
          Writeln('Password: ', Password);
          Writeln('Do you want to modify this password? (y/n)');
          Repeat
            Readln(Choice);
            Choice := UpCase(Choice);
            If Not (Choice In ['Y', 'N']) Then
              Writeln('Invalid input. Try again.');
          Until (Choice = 'Y') Or (Choice = 'N');

          If Choice = 'Y' Then
            Begin
              Write('Enter the new password: ');
              Readln(Password);
              EncryptDecrypt(Password, Passwords[i].Password);
              SavePasswordsToFile;
              Writeln('Password modified.');
            End
          Else
            Writeln('Modification canceled.');

          Exit;
        End;
    End;

  Writeln('Password not found for the given name.');
End;

Procedure ShiftPasswordsArray(StartIndex: Integer);

Var 
  i: Integer;
Begin
  For i := StartIndex To PasswordCount - 1 Do
    Passwords[i] := Passwords[i + 1];
  Dec(PasswordCount);
End;

Procedure DeletePasswordByName;

Var 
  Name: String;
  i: Integer;
  DecryptedPassword: String;
  Choice: Char;
Begin
  Write('Enter name of the password to delete: ');
  Readln(Name);
  For i := 1 To PasswordCount Do
    Begin
      If Passwords[i].Name = Name Then
        Begin
          EncryptDecrypt(Passwords[i].Password, DecryptedPassword);
          Writeln('Password found for the given name:');
          Writeln('Name: ', Passwords[i].Name);
          Writeln('Password: ', DecryptedPassword);
          Writeln('Do you want to proceed with the deletion? (Y/n)');
          Repeat
            Readln(Choice);
            Choice := UpCase(Choice);
            If Not (Choice In ['Y', 'N']) Then
              Writeln('Invalid input. Try again.');
          Until (Choice = 'Y') Or (Choice = 'N');

          If Choice = 'Y' Then
            Begin
              ShiftPasswordsArray(i);
              SavePasswordsToFile;
              Writeln('Password deleted.');
            End
          Else
            Writeln('Deletion canceled.');

          Exit;
        End;
    End;

  Writeln('Password not found for the given name.');
End;

Procedure DisplayPasswords;

Var 
  i: Integer;
  DecryptedPassword: String;
Begin
  Writeln('Password List:');
  For i := 1 To PasswordCount Do
    Begin
      EncryptDecrypt(Passwords[i].Password, DecryptedPassword);
      Writeln(i, '. Name: ', Passwords[i].Name);
      Writeln('   Password: ', DecryptedPassword);
    End;
End;

Procedure MainLoop;

Var 
  Choice: Char;
Begin
  Repeat
    Writeln;
    Writeln('Menu:');
    Writeln('1. Add a password');
    Writeln('2. Modify a password');
    Writeln('3. Display passwords');
    Writeln('4. Delete a password by name');
    Writeln('5. Exit');
    Write('Enter your choice: ');
    Readln(Choice);
    Case Choice Of 
      '1': AddPassword;
      '2': ModifyPassword;
      '3': DisplayPasswords;
      '4': DeletePasswordByName;
      '5': Writeln('Exiting...');
      Else
        Writeln('Invalid choice. Try again.');
    End;
  Until Choice = '5';
End;

Begin
  InitializePasswords;
  LoadPasswordsFromFile;
  MainLoop;
End.
