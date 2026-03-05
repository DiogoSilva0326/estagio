using Synget.ERPIntegrator.Models;

namespace ConfidantPostgreSQL.Integrations.Moloni
{
    /// <summary>
    /// Implementação desativada do serviço Moloni
    /// Usado quando o Moloni não está configurado
    /// </summary>
    public sealed class MoloniDisabledService : IMoloniService
    {
        public static readonly MoloniDisabledService Instance = new();

        public bool IsEnabled => false;
        public string LastMessage => "Moloni não está configurado";
        public int MainWarehouseId => 0;
        public int ReserveWarehouseId => 0;

        private MoloniDisabledService() { }

        public ERPProduct? GetProduct(string productId) => null;
        public List<ERPProduct> GetProducts(bool onlyWithStock = true) => new();
        public bool SaveProduct(ERPProduct product) => false;
        public bool SaveCustomer(ERPCustomer customer) => false;
        public string? CreatePurchaseOrder(ERPDocument document) => null;
        public bool CancelPurchaseOrder(string documentId) => false;
        public ERPDocument? InvoicePurchaseOrder(string documentId, ERPCustomer customer) => null;
        public string? GetDocumentPdfLink(string documentId, bool signed = false) => null;
        public int GetProductStock(string productId) => 0;
        public bool AddStockMovement(string productId, int quantity, string? notes = null) => false;
        public Task<int> SyncStockToLocalAsync(CancellationToken cancellationToken = default) => Task.FromResult(0);
    }
}
