private with Ada.Strings.Unbounded;

package Alire.Origins with Preelaborate is

   --  Minimal information about origins of sources.
   --  We use the term origins to avoid mixing 'alire sources' with 'project sources' or other 'sources'.

   --  The actual capabilities for check-outs or fetches are in alr proper

   type Kinds is (Apt,        -- Native platform package
                  Filesystem, -- Not really an origin, but a working copy of a project
                  Git,        -- Remote git repo
                  Hg          -- Remote hg repo
                 );

   type Origin is tagged private;

   function Kind (This : Origin) return Kinds;

   function URL (This : Origin) return Alire.URL;

   function Id (This : Origin) return String;

   --  Helper types

   subtype Git_Commit is String (1 .. 40);
   subtype Hg_Commit  is String (1 .. 40);

   --  Constructors

   function New_Filesystem (URL_As_Path : String) return Origin;

   function New_Git (URL  : Alire.URL;
                     Id   : Git_Commit)
                     return Origin;

   function New_Hg (URL  : Alire.URL;
                    Id   : Hg_Commit)
                    return Origin;

   function New_Apt (Id_As_Package_Name : String) return Origin;

   function Image (This : Origin) return String;

private

   use Ada.Strings.Unbounded;

   type Origin is tagged record
      Kind : Kinds;
      URL  : Unbounded_String;
      Id   : Unbounded_String;
   end record;

   function New_Filesystem (URL_As_Path : String) return Origin is
     (Filesystem,
      Null_Unbounded_String,
      To_Unbounded_String (URL_As_Path));

   function New_Git (URL  : Alire.URL;
                     Id   : Git_Commit)
                     return Origin is
     (Git,
      To_Unbounded_String (URL),
      To_Unbounded_String (Id));

   function New_Hg (URL  : Alire.URL;
                    Id   : Hg_Commit)
                    return Origin is
     (Hg,
      To_Unbounded_String (URL),
      To_Unbounded_String (Id));

   function New_Apt (Id_As_Package_Name : String) return Origin is
     (Apt,
      To_Unbounded_String (Id_As_Package_Name),
      Null_Unbounded_String);

   function Kind (This : Origin) return Kinds is (This.Kind);

   function URL (This : Origin) return Alire.URL is (Alire.URL (To_String (This.URL)));

   function Id (This : Origin) return String is (To_String (This.Id));

   function S (Str : Unbounded_String) return String is (To_String (Str));

   function Image (This : Origin) return String is
     (case This.Kind is
         when Git | Hg => "commit " & S (This.Id) & " from " & S (This.URL),
         when Apt => "package " & S (This.Id) & " from native package manager (apt)",
         when Filesystem => "path " & S (This.Id));


end Alire.Origins;
