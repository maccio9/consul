class Admin::ReportsController < Admin::BaseController

  def download_excel
    @proposals = Proposal.all
    @url = request.base_url
    render xlsx: 'download_excel'
  end

end
