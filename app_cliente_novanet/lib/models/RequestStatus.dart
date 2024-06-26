// ignore_for_file: file_names, non_constant_identifier_names

class Usuario {
  int? user_Id;
  String user_NombreUsuario;
  int? empl_Id;
  String? user_Contrasena;
  bool? user_Admin;
  int? role_Id;
  String? role_Descripcion;
  String? nombreEmpleado;
  int? user_UserCrea;

  Usuario(
      {this.user_Id,
      required this.user_NombreUsuario,
      this.empl_Id,
      this.user_Contrasena,
      this.user_Admin,
      this.role_Id,
      this.role_Descripcion,
      this.nombreEmpleado,
      this.user_UserCrea});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      user_Id: json['user_Id'],
      user_NombreUsuario: json['user_NombreUsuario'],
      empl_Id: json['empl_Id'],
      user_Contrasena: json['user_Contraseña'],
      user_Admin: json['user_Admin'],
      role_Id: json['role_Id'],
      role_Descripcion: json['role_Descripcion'],
      nombreEmpleado: json['nombreEmpleado'],
      user_UserCrea: json['user_UserCrea'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_Id": user_Id,
      "user_NombreUsuario": user_NombreUsuario,
      "empl_Id": empl_Id,
      "user_Contraseña": user_Contrasena,
      "user_Admin": user_Admin,
      "role_Id": role_Id,
      "role_Descripcion": role_Descripcion,
      "nombreEmpleado": nombreEmpleado,
      "user_UserCrea": user_UserCrea,
    };
  }
}

class UsuarioCreate {
  int fiIdcliente;
  String? fcUsuarioAcceso;
  String? fcPassword;
  
  UsuarioCreate(
      {required this.fiIdcliente,
      this.fcUsuarioAcceso,
      this.fcPassword,
      });

  factory UsuarioCreate.fromJson(Map<String, dynamic> json) {
    return UsuarioCreate(
      fiIdcliente: json['fiIdcliente'],
      fcUsuarioAcceso: json['fcUsuarioAcceso'],
      fcPassword: json['fcPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fiIdcliente": fiIdcliente,
      "fcUsuarioAcceso": fcUsuarioAcceso,
      "fcPassword": fcPassword,
    };
  }
}

class UsuarioEdit {
  int? user_Id;
  String? user_NombreUsuario;
  int? empl_Id;
  String? user_Contrasena;
  bool? user_Admin;
  int? role_Id;
  int? user_UserModifica;

  UsuarioEdit(
      {this.user_Id,
      this.user_NombreUsuario,
      this.empl_Id,
      this.user_Contrasena,
      this.user_Admin,
      this.role_Id,
      this.user_UserModifica});

  factory UsuarioEdit.fromJson(Map<String, dynamic> json) {
    return UsuarioEdit(
      user_Id: json['user_Id'],
      user_NombreUsuario: json['user_NombreUsuario'],
      empl_Id: json['empl_Id'],
      user_Contrasena: json['user_Contraseña'],
      user_Admin: json['user_Admin'],
      role_Id: json['role_Id'],
      user_UserModifica: json['user_UserModifica'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_Id": user_Id,
      "user_NombreUsuario": user_NombreUsuario,
      "empl_Id": empl_Id,
      "user_Contraseña": user_Contrasena,
      "user_Admin": user_Admin,
      "role_Id": role_Id,
      "user_UserModifica": user_UserModifica,
    };
  }
}

class UsuarioDelete {
  int? user_Id;

  UsuarioDelete({
    this.user_Id,
  });

  factory UsuarioDelete.fromJson(Map<String, dynamic> json) {
    return UsuarioDelete(
      user_Id: json['user_Id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_Id": user_Id,
    };
  }
}
