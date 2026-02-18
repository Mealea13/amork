namespace AmorkApp.Controllers
{
    public class ValidatePromoRequest
    {
        public string Code { get; set; } = string.Empty;
        public decimal OrderAmount { get; set; }
    }
}
