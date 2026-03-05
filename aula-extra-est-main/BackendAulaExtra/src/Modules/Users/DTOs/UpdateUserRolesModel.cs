using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Users.DTOs
{
    public class UpdateUserRolesModel
    {
        public System.Guid UserId { get; set; }

        // Mantém compatibilidade com o payload antigo:
        // { "userId": 4, "userRoles": [ { "roleId": 1 }, { "roleId": 2 } ] }
        public List<UpdateUserRoleItem> UserRoles { get; set; } = new List<UpdateUserRoleItem>();
    }

    public class UpdateUserRoleItem
    {
        public int RoleId { get; set; }
    }
}
