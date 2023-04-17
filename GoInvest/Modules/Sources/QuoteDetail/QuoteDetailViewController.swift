import UIKit
import Theme
import QuoteClient
import DomainModels
import SkeletonView

enum GraphState {
    case load
    case error
    case success
}
enum DetailState {
    case load
    case error
    case success
}
enum QuoteDetailViewState {
    case load
    case error
    case success
}

public class QuoteDetailViewController: UIViewController {
    private var quoteDetailClient: DetailProvider? = QuoteClient()
    private var chartDataClient: ChartsProvider? = QuoteClient()
    private var graphData: QuoteCharts?
    private var detailsData: QuoteDetail?
    private var quoteId: String?

    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.tryAgainHandler = { [weak self] in
            self?.getQuoteData()
        }
        return view
    }()
    private lazy var quoteDetailView: QuoteDetailView = {
        let view = QuoteDetailView()
        view.isSkeletonable = true
        return view
    }()
    private lazy var graphView: GraphView = {
        let view = GraphView()
        view.isSkeletonable = true
        return view
    }()
    private lazy var quoteDetailMainStackView: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [graphView, quoteDetailView])
        stack.spacing = Theme.bigSpacing
        stack.axis = .vertical
        stack.isSkeletonable = true
        return stack
    }()

    private var viewState: QuoteDetailViewState? {
        didSet {
            switch viewState {
            case .load:
                view.showAnimatedGradientSkeleton()
            case .success:
                view.hideSkeleton()
                errorView.isHidden = true
                graphView.graphData = graphData
                if let quoteDetailData = detailsData {
                    quoteDetailView.setDetailsData(quoteDetailData: quoteDetailData)
                }
            case .error:
                view.addSubview(errorView)
                layoutErrorView()
            case .none:
                break
            }
        }
    }
    private var graphState: GraphState? {
        didSet {
            switch graphState {
            case .load:
                viewState = .load
            case .error:
                viewState = .error
            case .success:
                if detailState == .success {
                    viewState = .success
                }
            case .none:
                break
            }
        }
    }
    private var detailState: DetailState? {
        didSet {
            switch detailState {
            case .load:
                viewState = .load
            case .error:
                viewState = .error
            case .success:
                if graphState == .success {
                    viewState = .success
                }
            case .none:
                break
            }
        }
    }

    public init(quoteId: String) {
        self.quoteId = quoteId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getQuoteData()
        setupLayout()
    }
}

// MARK: - UI and Layout
private extension QuoteDetailViewController {
    func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        view.isSkeletonable = true
        quoteDetailMainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quoteDetailMainStackView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            graphView.heightAnchor.constraint(equalToConstant: 300),
            quoteDetailMainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.topOffset),
            quoteDetailMainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.sideOffset),
            quoteDetailMainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.sideOffset),
            quoteDetailMainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func layoutErrorView() {
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.topOffset),
            errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.sideOffset),
            errorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.sideOffset),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Work with client
private extension QuoteDetailViewController {
    func getQuoteData() {
        getDataForGraph()
        getDataForDetails()
    }

    func getDataForDetails() {
        detailState = .load
        quoteDetailClient?.quoteDetail(id: quoteId ?? "") { [weak self] result in
            switch result {
            case .success(let quoteDetail):
                self?.detailsData = quoteDetail
                DispatchQueue.main.async {
                    self?.detailState = .success
                }
            case .failure:
                self?.detailState = .error
            }
        }
    }

    func getDataForGraph() {
        graphState = .load
        chartDataClient?.quoteCharts(id: quoteId ?? "", boardId: "TQBR", fromDate: Date()) { [weak self] result in
            switch result {
            case .success(let graphData):
                self?.graphData = graphData
                DispatchQueue.main.async {
                    self?.graphState = .success
                }
            case .failure:
                self?.graphState = .error
            }
        }
    }
}
