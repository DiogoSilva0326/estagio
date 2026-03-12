using Synget.ERPIntegrator;
using Synget.ERPIntegrator.Models;

namespace ConfidantPostgreSQL.Integrations.Moloni
{
    /// <summary>
    /// Implementação do serviço Moloni usando Synget.ERPIntegrator
    /// </summary>
    public sealed class MoloniService : IMoloniService
    {
        private readonly IERP _erp;
        private readonly ILogger<MoloniService> _logger;
        private readonly bool _enabled;
        private string _lastMessage = string.Empty;

        public bool IsEnabled => _enabled;
        public string LastMessage => _lastMessage;

        public MoloniService(ILogger<MoloniService> logger)
        {
            _logger = logger;
            _erp = new ERPMoloni();

            var config = BuildConfigFromEnvironment();
            
            if (config.Software == ERPSoftware.None)
            {
                _enabled = false;
                _lastMessage = "Moloni não configurado - variáveis de ambiente em falta";
                _logger.LogWarning("Moloni ERP não está configurado");
                return;
            }

            try
            {
                _enabled = _erp.Initialize(config);
                _lastMessage = _erp.Message;

                if (_enabled)
                {
                    _logger.LogInformation("Moloni ERP inicializado com sucesso");
                }
                else
                {
                    _logger.LogError("Falha ao inicializar Moloni: {Message}", _lastMessage);
                }
            }
            catch (Exception ex)
            {
                _enabled = false;
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Exceção ao inicializar Moloni");
            }
        }

        private static ERPConfig BuildConfigFromEnvironment()
        {
            var clientId = Environment.GetEnvironmentVariable("MOLONI_CLIENT_ID") ?? string.Empty;
            var clientSecret = Environment.GetEnvironmentVariable("MOLONI_CLIENT_SECRET") ?? string.Empty;
            var username = Environment.GetEnvironmentVariable("MOLONI_USERNAME") ?? string.Empty;
            var password = Environment.GetEnvironmentVariable("MOLONI_PASSWORD") ?? string.Empty;
            var companyIdStr = Environment.GetEnvironmentVariable("MOLONI_COMPANY_ID") ?? "0";
            var customerIdCFStr = Environment.GetEnvironmentVariable("MOLONI_CUSTOMER_ID_CF") ?? "0";
            var warehouseMainStr = Environment.GetEnvironmentVariable("MOLONI_WAREHOUSE_ID_MAIN") ?? "0";
            var warehouseReservStr = Environment.GetEnvironmentVariable("MOLONI_WAREHOUSE_ID_RESERV") ?? "0";
            var productionStr = Environment.GetEnvironmentVariable("MOLONI_PRODUCTION") ?? "true";

            if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(clientSecret))
            {
                return new ERPConfig { Software = ERPSoftware.None };
            }

            return new ERPConfig
            {
                Software = ERPSoftware.Moloni,
                MoloniProduction = bool.TryParse(productionStr, out var prod) && prod,
                MoloniClientID = clientId,
                MoloniClientSecret = clientSecret,
                MoloniUsername = username,
                MoloniPassword = password,
                MoloniCompanyID = int.TryParse(companyIdStr, out var cid) ? cid : 0,
                MoloniCustomerIDCF = int.TryParse(customerIdCFStr, out var cfid) ? cfid : 0,
                MoloniWarehouseIDMain = int.TryParse(warehouseMainStr, out var wmain) ? wmain : 0,
                MoloniWarehouseIDReserv = int.TryParse(warehouseReservStr, out var wreserv) ? wreserv : 0
            };
        }

        #region Produtos

        public ERPProduct? GetProduct(string productId)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return null;
            }

            try
            {
                var product = _erp.ProductGet(productId);
                _lastMessage = _erp.Message;
                return product;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao obter produto {ProductId} do Moloni", productId);
                return null;
            }
        }

        public List<ERPProduct> GetProducts(bool onlyWithStock = true)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return new List<ERPProduct>();
            }

            try
            {
                var products = _erp.ProductGetList(onlyWithStock);
                _lastMessage = _erp.Message;
                return products ?? new List<ERPProduct>();
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao obter lista de produtos do Moloni");
                return new List<ERPProduct>();
            }
        }

        public bool SaveProduct(ERPProduct product)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return false;
            }

            try
            {
                var isUpdate = !string.IsNullOrWhiteSpace(product.ID);
                _logger.LogInformation(
                    "[MoloniService.SaveProduct] {Action}: ID={Id}, Name='{Name}', Price={Price}, CategoryID={CatId}, IsService={IsService}",
                    isUpdate ? "UPDATE" : "INSERT", product.ID ?? "(novo)", product.Name, product.Price, product.CategoryID, product.IsService);

                var result = _erp.ProductSave(product);
                _lastMessage = _erp.Message;
                
                if (result)
                {
                    _logger.LogInformation(
                        "[MoloniService.SaveProduct] Sucesso! ProductID retornado: {ProductId}, Message: {Message}",
                        product.ID, _lastMessage ?? "(vazio)");
                }
                else
                {
                    _logger.LogWarning(
                        "[MoloniService.SaveProduct] Falha ao guardar produto. Message: {Message}",
                        _lastMessage ?? "(vazio)");
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao guardar produto {ProductId} no Moloni", product.ID);
                return false;
            }
        }

        #endregion

        #region Clientes

        public bool SaveCustomer(ERPCustomer customer)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return false;
            }

            try
            {
                var result = _erp.CustomerSave(customer);
                _lastMessage = _erp.Message;
                
                if (result)
                {
                    _logger.LogInformation("Cliente {CustomerName} guardado no Moloni", customer.Name);
                }
                else
                {
                    _logger.LogWarning("Falha ao guardar cliente {CustomerName}: {Message}", customer.Name, _lastMessage);
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao guardar cliente {CustomerId} no Moloni", customer.ID);
                return false;
            }
        }

        #endregion

        #region Documentos

        public string? CreatePurchaseOrder(ERPDocument document)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return null;
            }

            try
            {
                var result = _erp.PurchaseOrderSave(document);
                _lastMessage = _erp.Message;
                
                if (result)
                {
                    _logger.LogInformation("Encomenda criada no Moloni com ID: {DocumentId}", document.ID);
                    return document.ID;
                }
                
                _logger.LogWarning("Falha ao criar encomenda no Moloni: {Message}", _lastMessage);
                return null;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao criar encomenda no Moloni");
                return null;
            }
        }

        public bool CancelPurchaseOrder(string documentId)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return false;
            }

            try
            {
                var result = _erp.PurchaseOrderCancel(documentId);
                _lastMessage = _erp.Message;
                
                if (result)
                {
                    _logger.LogInformation("Encomenda {DocumentId} cancelada no Moloni", documentId);
                }
                else
                {
                    _logger.LogWarning("Falha ao cancelar encomenda {DocumentId}: {Message}", documentId, _lastMessage);
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao cancelar encomenda {DocumentId} no Moloni", documentId);
                return false;
            }
        }

        public ERPDocument? InvoicePurchaseOrder(string documentId, ERPCustomer customer)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return null;
            }

            try
            {
                var invoice = _erp.PurchaseOrderInvoice(documentId, customer);
                _lastMessage = _erp.Message;
                
                if (invoice != null)
                {
                    _logger.LogInformation("Fatura criada no Moloni: {InvoiceId} para encomenda {DocumentId}", 
                        invoice.ID, documentId);
                }
                else
                {
                    _logger.LogWarning("Falha ao faturar encomenda {DocumentId}: {Message}", documentId, _lastMessage);
                }
                
                return invoice;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao faturar encomenda {DocumentId} no Moloni", documentId);
                return null;
            }
        }

        public string? GetDocumentPdfLink(string documentId, bool signed = false)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return null;
            }

            try
            {
                if (_erp is not ERPMoloni moloni)
                {
                    _lastMessage = "ERP Moloni não disponível";
                    return null;
                }

                var url = moloni.DocumentGetPdfLink(documentId, signed);
                _lastMessage = _erp.Message;
                return string.IsNullOrWhiteSpace(url) ? null : url;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao obter PDF do documento {DocumentId} no Moloni", documentId);
                return null;
            }
        }

        #endregion

        #region Stock

        public int MainWarehouseId
        {
            get
            {
                if (_erp is ERPMoloni moloni && moloni.MLN?.Config != null)
                    return moloni.MLN.Config.WarehouseIDMain ?? 0;
                return 0;
            }
        }

        public int ReserveWarehouseId
        {
            get
            {
                if (_erp is ERPMoloni moloni && moloni.MLN?.Config != null)
                    return moloni.MLN.Config.WarehouseIDReserv ?? 0;
                return 0;
            }
        }

        public int GetProductStock(string productId)
        {
            if (!_enabled) return 0;

            try
            {
                var product = _erp.ProductGet(productId);
                if (product != null)
                {
                    return (int)product.StockTotal;
                }
                return 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter stock do produto {ProductId}", productId);
                return 0;
            }
        }

        public bool AddStockMovement(string productId, int quantity, string? notes = null)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return false;
            }

            if (string.IsNullOrWhiteSpace(productId) || !int.TryParse(productId, out var pid) || pid <= 0)
            {
                _lastMessage = "ID de produto inválido";
                return false;
            }

            try
            {
                if (_erp is not ERPMoloni moloni)
                {
                    _lastMessage = "ERP Moloni não disponível";
                    return false;
                }

                var warehouseId = moloni.MLN.Config.WarehouseIDMain;
                var result = moloni.MLN.Products.ProductStocksInsert(
                    pid,
                    DateTime.Now,
                    quantity,
                    warehouseId,
                    notes ?? "Ajuste de stock via backoffice"
                );

                if (!result.Success)
                {
                    _lastMessage = result.ToString();
                    _logger.LogWarning("Falha ao adicionar movimento de stock para produto {ProductId}: {Message}", productId, _lastMessage);
                    return false;
                }

                _lastMessage = string.Empty;
                _logger.LogInformation("Movimento de stock adicionado: produto {ProductId}, quantidade {Qty}, armazém {Warehouse}", 
                    productId, quantity, warehouseId);
                return true;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao adicionar movimento de stock para produto {ProductId}", productId);
                return false;
            }
        }

        public async Task<int> SyncStockToLocalAsync(CancellationToken cancellationToken = default)
        {
            if (!_enabled)
            {
                _lastMessage = "Moloni não está ativo";
                return 0;
            }

            try
            {
                // Obter todos os produtos com stock
                var products = _erp.ProductGetList(true);
                
                if (products == null || products.Count == 0)
                {
                    _logger.LogInformation("Nenhum produto com stock encontrado no Moloni");
                    return 0;
                }

                _logger.LogInformation("Sincronizando stock de {Count} produtos do Moloni", products.Count);
                
                // TODO: Implementar atualização na base de dados local
                // Isto será implementado quando integrarmos com o ProductsRepository
                
                await Task.CompletedTask;
                return products.Count;
            }
            catch (Exception ex)
            {
                _lastMessage = ex.Message;
                _logger.LogError(ex, "Erro ao sincronizar stock do Moloni");
                return 0;
            }
        }

        #endregion
    }
}
